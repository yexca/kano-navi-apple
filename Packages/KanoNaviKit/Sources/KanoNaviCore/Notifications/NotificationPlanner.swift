import Foundation

/// Pure, deterministic planner for diff-based notifications and future local reminders.
public enum NotificationPlanner {
    /// Maximum pending reminders scheduled with the OS, leaving headroom below
    /// Apple's 64-pending-notification ceiling.
    public static let maxScheduledReminders = 60

    /// Maximum age for newly discovered posts or videos so historical archive
    /// backfills never trigger immediate notifications.
    private static let backfillWindowSeconds: TimeInterval = 24 * 60 * 60
    private static let baselineGraceSeconds: TimeInterval = 5 * 60
    private static let maxUnbundledPerThread = 3
    private static let defaultDayReminderHour = 9

    public static func evaluate(
        dashboard: Dashboard,
        calendarEvents: [ScheduleEvent] = [],
        baseline: NotificationBaseline?,
        preferences: NotificationPreferences,
        now: Date = Date(),
        emitImmediate: Bool = true
    ) -> NotificationEvaluation {
        let mergedEvents = mergeEvents(dashboardEvents: dashboard.events, calendarEvents: calendarEvents)
        let updatedBaseline = buildBaseline(
            from: baseline,
            dashboard: dashboard,
            events: mergedEvents,
            now: now
        )

        guard preferences.isEnabled else {
            return NotificationEvaluation(baseline: updatedBaseline, immediate: [], reminders: [])
        }

        let reminders = planReminders(events: mergedEvents, preferences: preferences, now: now)

        guard emitImmediate, let previous = baseline else {
            return NotificationEvaluation(baseline: updatedBaseline, immediate: [], reminders: reminders)
        }

        let freshnessFloor = max(
            previous.establishedAt.addingTimeInterval(-baselineGraceSeconds),
            now.addingTimeInterval(-backfillWindowSeconds)
        )

        var rawImmediate: [PlannedNotification] = []
        rawImmediate.append(
            contentsOf: diffLiveAndEvents(
                dashboard: dashboard,
                events: mergedEvents,
                previous: previous,
                preferences: preferences,
                now: now
            )
        )
        rawImmediate.append(
            contentsOf: diffVideos(
                videos: dashboard.videos,
                events: mergedEvents,
                previous: previous,
                preferences: preferences,
                freshnessFloor: freshnessFloor,
                now: now
            )
        )
        rawImmediate.append(
            contentsOf: diffPosts(
                posts: dashboard.posts,
                previous: previous,
                preferences: preferences,
                freshnessFloor: freshnessFloor
            )
        )

        let immediate = coalesceBursts(rawImmediate, now: now)
        return NotificationEvaluation(
            baseline: updatedBaseline,
            immediate: immediate,
            reminders: reminders
        )
    }

    /// Computes future reminders alone from known schedule events.
    public static func planReminders(
        events: [ScheduleEvent],
        preferences: NotificationPreferences,
        now: Date = Date()
    ) -> [ScheduledReminder] {
        guard preferences.isEnabled else { return [] }
        var reminders: [ScheduledReminder] = []

        for event in events {
            let state = event.view?.state ?? .unknown("")
            if state == .cancelled || state == .cancellationReview || state == .done {
                continue
            }
            if !passesMembersFilter(event: event, preferences: preferences) {
                continue
            }

            if isSale(event) {
                reminders.append(contentsOf: saleReminders(for: event, preferences: preferences, now: now))
            } else if state == .upcoming || state == .pending {
                if let reminder = eventStartReminder(for: event, preferences: preferences, now: now) {
                    reminders.append(reminder)
                }
            }
        }

        reminders.sort { lhs, rhs in
            if lhs.triggerDate == rhs.triggerDate {
                return lhs.id < rhs.id
            }
            return lhs.triggerDate < rhs.triggerDate
        }
        if reminders.count > maxScheduledReminders {
            return Array(reminders.prefix(maxScheduledReminders))
        }
        return reminders
    }

    // MARK: - Baseline Construction

    private static func mergeEvents(
        dashboardEvents: [ScheduleEvent],
        calendarEvents: [ScheduleEvent]
    ) -> [ScheduleEvent] {
        var byID: [String: Int] = [:]
        var merged: [ScheduleEvent] = []
        for event in dashboardEvents {
            if let index = byID[event.id] {
                merged[index] = event
            } else {
                byID[event.id] = merged.count
                merged.append(event)
            }
        }
        for event in calendarEvents {
            if let index = byID[event.id] {
                merged[index] = event
            } else {
                byID[event.id] = merged.count
                merged.append(event)
            }
        }
        return merged
    }

    private static func buildBaseline(
        from existing: NotificationBaseline?,
        dashboard: Dashboard,
        events: [ScheduleEvent],
        now: Date
    ) -> NotificationBaseline {
        var next = existing ?? NotificationBaseline(establishedAt: now)
        if let revision = dashboard.meta.revision {
            next.lastRevision = revision
        }
        if let liveNow = dashboard.liveNow {
            next.lastLiveNowKey = liveNowKey(liveNow)
        }
        for post in dashboard.posts.reversed() {
            next.recordPost(post.id)
        }
        for video in dashboard.videos.reversed() {
            next.recordVideo(video.id, shelfGroup: video.view?.shelfGroup ?? "")
        }
        for event in events {
            let snapshot = RecordedEventSnapshot(
                state: event.view?.state ?? .unknown(""),
                startsOn: event.startsOn,
                startsAt: event.startsAt
            )
            next.recordEvent(event.id, snapshot: snapshot)
        }
        return next
    }

    // MARK: - Live & Schedule Diffing

    private static func diffLiveAndEvents(
        dashboard: Dashboard,
        events: [ScheduleEvent],
        previous: NotificationBaseline,
        preferences: NotificationPreferences,
        now: Date
    ) -> [PlannedNotification] {
        var notifications: [PlannedNotification] = []

        if let liveNow = dashboard.liveNow {
            let key = liveNowKey(liveNow)
            if key != previous.lastLiveNowKey, preferences.notifyLiveNow {
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.live.unscheduled.\(Int(liveNow.startedAt.timeIntervalSince1970))",
                        thread: .live,
                        route: .now,
                        kind: .unscheduledLive(liveNow)
                    )
                )
            }
        }

        let recentDayFloor = JapanDate.date(from: now.addingTimeInterval(-backfillWindowSeconds))

        for event in events {
            let state = event.view?.state ?? .unknown("")
            let recorded = previous.seenEvents[event.id]
            let membersAllowed = passesMembersFilter(event: event, preferences: preferences)

            if state == .live, recorded?.state != .live {
                if preferences.notifyLiveNow, membersAllowed {
                    notifications.append(
                        PlannedNotification(
                            id: "kanonavi.live.event.\(event.id)",
                            thread: .live,
                            route: .event(id: event.id),
                            kind: .eventLive(event)
                        )
                    )
                }
                continue
            }

            guard passesScheduleFilter(event: event, preferences: preferences) else {
                continue
            }

            if let recorded {
                guard preferences.schedule.cancellationsAndChanges else { continue }
                let becameCancelled =
                    (state == .cancelled || state == .cancellationReview)
                    && recorded.state != .cancelled
                    && recorded.state != .cancellationReview
                if becameCancelled {
                    notifications.append(
                        PlannedNotification(
                            id: "kanonavi.event.cancelled.\(event.id)",
                            thread: .schedule,
                            route: .event(id: event.id),
                            kind: .eventCancelled(event)
                        )
                    )
                    continue
                }

                let stillUpcoming = state == .upcoming || state == .open || state == .pending
                let dayChanged = recorded.startsOn != event.startsOn
                let timeChanged =
                    recorded.startsAt != nil
                    && event.startsAt != nil
                    && recorded.startsAt != event.startsAt
                if stillUpcoming, dayChanged || timeChanged {
                    let stamp =
                        event.startsAt.map { String(Int($0.timeIntervalSince1970)) }
                        ?? event.startsOn.rawValue
                    notifications.append(
                        PlannedNotification(
                            id: "kanonavi.event.rescheduled.\(event.id).\(stamp)",
                            thread: .schedule,
                            route: .event(id: event.id),
                            kind: .eventRescheduled(event)
                        )
                    )
                }
            } else {
                guard preferences.schedule.newEvents else { continue }
                guard state == .upcoming || state == .open || state == .pending else { continue }
                let relevantDay = event.endsOn ?? event.startsOn
                let notExpired = event.endsAt.map { $0 > now } ?? (relevantDay >= recentDayFloor)
                guard notExpired else { continue }
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.event.new.\(event.id)",
                        thread: .schedule,
                        route: .event(id: event.id),
                        kind: .newEvent(event)
                    )
                )
            }
        }

        return notifications
    }

    // MARK: - Video Diffing

    private static func diffVideos(
        videos: [Video],
        events: [ScheduleEvent],
        previous: NotificationBaseline,
        preferences: NotificationPreferences,
        freshnessFloor: Date,
        now: Date
    ) -> [PlannedNotification] {
        guard preferences.videos.hasAnyEnabled else { return [] }
        let eventIdentities = collectEventURLIdentities(events)
        var notifications: [PlannedNotification] = []

        for video in videos {
            if !isWatchable(video: video, preferences: preferences) {
                continue
            }
            let group = video.view?.shelfGroup ?? ""
            let isShort = group == "short" || video.view?.formCode == .short || video.isShort == true
            let isArchive = group == "archive" || video.view?.formCode == .archive

            if let previousGroup = previous.seenVideoShelfGroups[video.id] {
                if previousGroup != "archive", isArchive, preferences.videos.archives {
                    let referenceDate = video.endsAt ?? video.publishedAt ?? video.scheduledAt ?? now
                    if referenceDate >= now.addingTimeInterval(-backfillWindowSeconds) {
                        notifications.append(
                            PlannedNotification(
                                id: "kanonavi.video.archive.\(video.id)",
                                thread: .videos,
                                route: .videos,
                                kind: .newVideo(video, isArchive: true, isShort: false)
                            )
                        )
                    }
                }
                continue
            }

            guard let timestamp = video.publishedAt ?? video.scheduledAt, timestamp >= freshnessFloor else {
                continue
            }

            if group == "reservation" {
                if sharesIdentity(video: video, with: eventIdentities) {
                    continue
                }
                guard video.view?.formCode == .premiere, preferences.videos.works else {
                    continue
                }
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.video.\(video.id)",
                        thread: .videos,
                        route: .videos,
                        kind: .newVideo(video, isArchive: false, isShort: false)
                    )
                )
                continue
            }

            if isShort {
                guard preferences.videos.shorts else { continue }
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.video.\(video.id)",
                        thread: .videos,
                        route: .videos,
                        kind: .newVideo(video, isArchive: false, isShort: true)
                    )
                )
            } else if isArchive {
                guard preferences.videos.archives else { continue }
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.video.\(video.id)",
                        thread: .videos,
                        route: .videos,
                        kind: .newVideo(video, isArchive: true, isShort: false)
                    )
                )
            } else if group == "work" || video.view?.formCode == .video || video.view?.formCode == .premiere {
                guard preferences.videos.works else { continue }
                notifications.append(
                    PlannedNotification(
                        id: "kanonavi.video.\(video.id)",
                        thread: .videos,
                        route: .videos,
                        kind: .newVideo(video, isArchive: false, isShort: false)
                    )
                )
            }
        }

        return notifications
    }

    // MARK: - Post Diffing

    private static func diffPosts(
        posts: [Post],
        previous: NotificationBaseline,
        preferences: NotificationPreferences,
        freshnessFloor: Date
    ) -> [PlannedNotification] {
        guard preferences.posts.hasAnyEnabled else { return [] }
        let seen = Set(previous.seenPostIDs)
        var notifications: [PlannedNotification] = []

        for post in posts {
            guard !seen.contains(post.id) else { continue }
            guard post.publishedAt >= freshnessFloor else { continue }
            guard matchesPostPreferences(post: post, settings: preferences.posts) else { continue }
            notifications.append(
                PlannedNotification(
                    id: "kanonavi.post.\(post.id)",
                    thread: .posts,
                    route: .posts,
                    kind: .newPost(post)
                )
            )
        }

        return notifications
    }

    private static func matchesPostPreferences(post: Post, settings: PostNotificationSettings) -> Bool {
        if post.promoted == true {
            return settings.promotedPosts
        }
        if post.source == "bilibili" {
            return settings.bilibiliPosts
        }
        return settings.ownXPosts
    }

    // MARK: - Burst Coalescing

    private static func coalesceBursts(
        _ notifications: [PlannedNotification],
        now: Date
    ) -> [PlannedNotification] {
        var grouped: [NotificationThread: [PlannedNotification]] = [:]
        for item in notifications {
            grouped[item.thread, default: []].append(item)
        }

        var result: [PlannedNotification] = []
        for thread in NotificationThread.allCases {
            guard let items = grouped[thread], !items.isEmpty else { continue }
            if items.count <= maxUnbundledPerThread {
                result.append(contentsOf: items)
            } else {
                let head = items.prefix(2)
                result.append(contentsOf: head)
                let remaining = items.count - head.count
                result.append(
                    PlannedNotification(
                        id: "\(thread.rawValue).summary.\(Int(now.timeIntervalSince1970))",
                        thread: thread,
                        route: summaryRoute(for: thread, now: now),
                        kind: .summary(thread: thread, additionalCount: remaining)
                    )
                )
            }
        }
        return result
    }

    private static func summaryRoute(for thread: NotificationThread, now: Date) -> NotificationRoute {
        switch thread {
        case .live: .now
        case .schedule, .reminders: .schedule(date: JapanDate.date(from: now))
        case .videos: .videos
        case .posts: .posts
        }
    }

    // MARK: - Timed Reminder Helpers

    private static func eventStartReminder(
        for event: ScheduleEvent,
        preferences: NotificationPreferences,
        now: Date
    ) -> ScheduledReminder? {
        guard let offset = preferences.eventReminderLead.offsetSeconds else { return nil }
        guard preferences.schedule.categories.contains(scheduleCategory(for: event)) else {
            return nil
        }
        if preferences.schedule.confirmedOnly, !isConfirmed(event), event.liveStatus == nil {
            return nil
        }
        guard let startsAt = event.startsAt,
            hasClockTime(startsAt: startsAt, precision: event.timePrecision),
            startsAt > now
        else {
            return nil
        }
        let triggerDate = startsAt.addingTimeInterval(-offset)
        guard triggerDate > now else { return nil }
        return ScheduledReminder(
            id: "kanonavi.reminder.event.\(event.id).\(preferences.eventReminderLead.rawValue)",
            triggerDate: triggerDate,
            route: .event(id: event.id),
            kind: .eventStart(event: event, lead: preferences.eventReminderLead, startsAt: startsAt)
        )
    }

    private static func saleReminders(
        for event: ScheduleEvent,
        preferences: NotificationPreferences,
        now: Date
    ) -> [ScheduledReminder] {
        var result: [ScheduledReminder] = []
        let entries = event.view?.calendarEntries ?? []

        if preferences.notifySaleOpens, let open = saleOpenMoment(event: event, entries: entries) {
            let clockKnown = hasClockTime(startsAt: open.time, precision: open.precision)
            let trigger: Date? =
                if clockKnown, let time = open.time {
                    time
                } else {
                    morningInJapan(on: open.date)
                }
            if let trigger, trigger > now {
                result.append(
                    ScheduledReminder(
                        id: "kanonavi.reminder.sale.open.\(event.id)",
                        triggerDate: trigger,
                        route: .event(id: event.id),
                        kind: .saleOpens(
                            event: event,
                            date: open.date,
                            instant: trigger,
                            hasClockTime: clockKnown
                        )
                    )
                )
            }
        }

        if let offset = preferences.saleCloseLead.offsetSeconds,
            let close = saleCloseMoment(event: event, entries: entries)
        {
            let clockKnown = hasClockTime(startsAt: close.time, precision: close.precision)
            if clockKnown, let closesAt = close.time {
                let trigger = closesAt.addingTimeInterval(-offset)
                if closesAt > now, trigger > now {
                    result.append(
                        ScheduledReminder(
                            id:
                                "kanonavi.reminder.sale.close.\(event.id).\(preferences.saleCloseLead.rawValue)",
                            triggerDate: trigger,
                            route: .event(id: event.id),
                            kind: .saleCloses(
                                event: event,
                                lead: preferences.saleCloseLead,
                                date: close.date,
                                instant: closesAt,
                                hasClockTime: true
                            )
                        )
                    )
                }
            } else {
                let reminderDay =
                    preferences.saleCloseLead == .twentyFourHours
                    ? close.date.addingDays(-1)
                    : close.date
                if let trigger = morningInJapan(on: reminderDay), trigger > now {
                    result.append(
                        ScheduledReminder(
                            id:
                                "kanonavi.reminder.sale.close.\(event.id).\(preferences.saleCloseLead.rawValue)",
                            triggerDate: trigger,
                            route: .event(id: event.id),
                            kind: .saleCloses(
                                event: event,
                                lead: preferences.saleCloseLead,
                                date: close.date,
                                instant: trigger,
                                hasClockTime: false
                            )
                        )
                    )
                }
            }
        }

        return result
    }

    private static func saleOpenMoment(
        event: ScheduleEvent,
        entries: [CalendarEntryView]
    ) -> (date: JapanDate, time: Date?, precision: String)? {
        if let open = entries.first(where: { $0.saleMark == .opens }) {
            return (open.startsOn, open.startsAt, open.timePrecision)
        }
        if let window = event.saleWindow {
            return (window.startsOn, window.startsAt, window.startsAt == nil ? "date" : "exact")
        }
        return nil
    }

    private static func saleCloseMoment(
        event: ScheduleEvent,
        entries: [CalendarEntryView]
    ) -> (date: JapanDate, time: Date?, precision: String)? {
        if let close = entries.first(where: { $0.saleMark == .closes }) {
            return (close.startsOn, close.startsAt, close.timePrecision)
        }
        if let window = event.saleWindow, let endsOn = window.endsOn {
            return (endsOn, window.endsAt, window.endsAt == nil ? "date" : "exact")
        }
        return nil
    }

    private static func morningInJapan(on date: JapanDate) -> Date? {
        JapanTime.startOfDay(date)?.addingTimeInterval(TimeInterval(defaultDayReminderHour * 3600))
    }

    private static func hasClockTime(startsAt: Date?, precision: String) -> Bool {
        startsAt != nil && precision != "date" && precision != "unknown"
    }

    // MARK: - Classification & Identity Helpers

    public static func scheduleCategory(for event: ScheduleEvent) -> ScheduleNotificationCategory {
        if isSale(event) {
            return .sale
        }
        switch event.view?.typeCode {
        case "stream", "member":
            return .stream
        case "event":
            return .event
        case "release", "video":
            return .release
        case "sale":
            return .sale
        default:
            if event.view?.isWork == true {
                return .release
            }
            if event.eventType == "event" {
                return .event
            }
            return .stream
        }
    }

    private static func isSale(_ event: ScheduleEvent) -> Bool {
        if event.view?.typeCode == "sale" || event.eventType == "sale" || event.saleWindow != nil {
            return true
        }
        return (event.view?.calendarEntries ?? []).contains { $0.saleMark != nil }
    }

    private static func isConfirmed(_ event: ScheduleEvent) -> Bool {
        event.provenance == "manual" || event.manualLocked
    }

    private static func passesMembersFilter(
        event: ScheduleEvent,
        preferences: NotificationPreferences
    ) -> Bool {
        if event.view?.typeCode == "member" || event.eventType == "member" {
            return preferences.includeMembersOnly
        }
        return true
    }

    private static func passesScheduleFilter(
        event: ScheduleEvent,
        preferences: NotificationPreferences
    ) -> Bool {
        guard passesMembersFilter(event: event, preferences: preferences) else { return false }
        guard preferences.schedule.categories.contains(scheduleCategory(for: event)) else { return false }
        if preferences.schedule.confirmedOnly, !isConfirmed(event) {
            return false
        }
        return true
    }

    private static func isWatchable(video: Video, preferences: NotificationPreferences) -> Bool {
        if video.isCancelled == true || video.view?.phase == .cancelled {
            return false
        }
        switch video.availability {
        case .private, .removed:
            return false
        case .members:
            return preferences.includeMembersOnly
        default:
            return true
        }
    }

    private static func liveNowKey(_ liveNow: LiveNow) -> String {
        "\(liveNow.url.absoluteString)|\(Int(liveNow.startedAt.timeIntervalSince1970))"
    }

    private static func collectEventURLIdentities(_ events: [ScheduleEvent]) -> Set<String> {
        var identities: Set<String> = []
        for event in events {
            if let url = event.url {
                identities.insert(canonicalIdentity(for: url))
            }
            if let liveURL = event.liveURL {
                identities.insert(canonicalIdentity(for: liveURL))
            }
            for link in event.links ?? [] {
                if let url = link.url {
                    identities.insert(canonicalIdentity(for: url))
                }
            }
        }
        return identities
    }

    private static func sharesIdentity(video: Video, with eventIdentities: Set<String>) -> Bool {
        if eventIdentities.contains(canonicalIdentity(for: video.url)) {
            return true
        }
        for alternate in video.alternates ?? [] {
            if eventIdentities.contains(canonicalIdentity(for: alternate.url)) {
                return true
            }
        }
        return false
    }

    private static func canonicalIdentity(for url: URL) -> String {
        let host = url.host?.lowercased() ?? ""
        if host == "youtu.be" {
            let id = url.pathComponents.filter { $0 != "/" }.first ?? ""
            if !id.isEmpty {
                return "yt:\(id)"
            }
        }
        if host == "youtube.com" || host.hasSuffix(".youtube.com") {
            let segments = url.pathComponents.filter { $0 != "/" }
            if segments.first == "watch",
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let id = components.queryItems?.first(where: { $0.name == "v" })?.value,
                !id.isEmpty
            {
                return "yt:\(id)"
            }
            if let first = segments.first, first == "live" || first == "shorts", segments.count >= 2 {
                return "yt:\(segments[1])"
            }
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }
        components.scheme = components.scheme?.lowercased()
        components.host = components.host?.lowercased()
        components.fragment = nil
        if components.path == "/" {
            components.path = ""
        }
        return components.string ?? url.absoluteString
    }
}
