import Foundation
import KanoNaviComponents
import KanoNaviCore

/// Formats planned notifications and scheduled reminders into localized banner
/// strings in the interface locale and the user's chosen content language.
enum NotificationCopyFormatter {
    private static let maxPostSnippetCharacters = 140

    static func format(
        _ notification: PlannedNotification,
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) -> LocalNotificationPayload {
        let title: String
        let subtitle: String
        let body: String

        switch notification.kind {
        case .unscheduledLive(let liveNow):
            title = localized(.Notifications.bannerLiveTitle, locale: interfaceLocale)
            subtitle = localized(DisplayCodeLabels.platform(liveNow.platform), locale: interfaceLocale)
            body = liveNow.title

        case .eventLive(let event):
            title = localized(.Notifications.bannerLiveTitle, locale: interfaceLocale)
            if let platform = event.platforms?.first ?? event.platform {
                subtitle = localized(DisplayCodeLabels.platform(platform), locale: interfaceLocale)
            } else {
                subtitle = ""
            }
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .newPost(let post):
            if post.promoted == true {
                title = localized(.Notifications.bannerPromotedPostTitle, locale: interfaceLocale)
            } else if post.source == "bilibili" {
                title = localized(.Notifications.bannerNewPostBilibiliTitle, locale: interfaceLocale)
            } else {
                title = localized(.Notifications.bannerNewPostXTitle, locale: interfaceLocale)
            }
            if case .x(let handle) = PostAccount(source: post.source, handle: post.accountHandle) {
                subtitle = "@\(handle)"
            } else {
                subtitle = ""
            }
            body = resolvePostSnippet(
                post, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .newVideo(let video, let isArchive, let isShort):
            if isArchive {
                title = localized(.Notifications.bannerNewArchiveTitle, locale: interfaceLocale)
            } else if isShort {
                title = localized(.Notifications.bannerNewShortTitle, locale: interfaceLocale)
            } else {
                title = localized(.Notifications.bannerNewVideoTitle, locale: interfaceLocale)
            }
            let platform = EventPlatform(videoSource: video.source)
            subtitle = localized(DisplayCodeLabels.platform(platform), locale: interfaceLocale)
            body = resolveVideoTitle(
                video, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .newEvent(let event):
            title = localized(.Notifications.bannerNewEventTitle, locale: interfaceLocale)
            subtitle = eventTimeSubtitle(event, locale: interfaceLocale)
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .eventCancelled(let event):
            title = localized(.Notifications.bannerEventCancelledTitle, locale: interfaceLocale)
            subtitle = eventTimeSubtitle(event, locale: interfaceLocale)
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .eventRescheduled(let event):
            title = localized(.Notifications.bannerEventRescheduledTitle, locale: interfaceLocale)
            subtitle = eventTimeSubtitle(event, locale: interfaceLocale)
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .summary(let thread, let additionalCount):
            let titleResource: LocalizedStringResource =
                switch thread {
                case .live: .Notifications.bannerSummaryLiveTitle
                case .schedule, .reminders: .Notifications.bannerSummaryScheduleTitle
                case .videos: .Notifications.bannerSummaryVideosTitle
                case .posts: .Notifications.bannerSummaryPostsTitle
                }
            title = localized(titleResource, locale: interfaceLocale)
            subtitle = ""
            body = localized(
                .Notifications.bannerSummaryBody(additionalCount),
                locale: interfaceLocale
            )
        }

        return LocalNotificationPayload(
            id: notification.id,
            title: title,
            subtitle: subtitle,
            body: body,
            threadIdentifier: notification.thread.rawValue,
            routeURL: notification.route.url,
            triggerDate: nil
        )
    }

    static func format(
        _ reminder: ScheduledReminder,
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) -> LocalNotificationPayload {
        let title: String
        let subtitle: String
        let body: String

        switch reminder.kind {
        case .eventStart(let event, let lead, let startsAt):
            let titleResource: LocalizedStringResource =
                switch lead {
                case .tenMinutes: .Notifications.bannerReminderStart10MTitle
                case .thirtyMinutes: .Notifications.bannerReminderStart30MTitle
                case .atStart, .off: .Notifications.bannerReminderStartNowTitle
                }
            title = localized(titleResource, locale: interfaceLocale)
            subtitle = JSTTimeFormat.time(startsAt, locale: interfaceLocale)
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .saleOpens(let event, let date, let instant, let hasClockTime):
            title = localized(.Notifications.bannerReminderSaleOpensTitle, locale: interfaceLocale)
            if hasClockTime {
                subtitle = JSTTimeFormat.dateTime(instant, locale: interfaceLocale)
            } else {
                let day = JSTTimeFormat.day(date, locale: interfaceLocale)
                subtitle = localized(
                    .Notifications.bannerReminderSaleOpensTodayBody(day),
                    locale: interfaceLocale
                )
            }
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)

        case .saleCloses(let event, _, let date, let instant, let hasClockTime):
            title = localized(.Notifications.bannerReminderSaleClosesTitle, locale: interfaceLocale)
            if hasClockTime {
                let when = JSTTimeFormat.dateTime(instant, locale: interfaceLocale)
                subtitle = localized(
                    .Notifications.bannerReminderSaleClosesAtBody(when),
                    locale: interfaceLocale
                )
            } else {
                let day = JSTTimeFormat.day(date, locale: interfaceLocale)
                subtitle = localized(
                    .Notifications.bannerReminderSaleClosesDayBody(day),
                    locale: interfaceLocale
                )
            }
            body = resolveEventTitle(
                event, contentLanguage: contentLanguage, interfaceLocale: interfaceLocale)
        }

        return LocalNotificationPayload(
            id: reminder.id,
            title: title,
            subtitle: subtitle,
            body: body,
            threadIdentifier: NotificationThread.reminders.rawValue,
            routeURL: reminder.route.url,
            triggerDate: reminder.triggerDate
        )
    }

    private static func resolveEventTitle(
        _ event: ScheduleEvent,
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) -> String {
        event.resolvedTitle(preference: contentLanguage, interfaceLocale: interfaceLocale).text
    }

    private static func resolveVideoTitle(
        _ video: Video,
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) -> String {
        ContentLanguageResolver.resolve(
            original: video.title,
            sourceLanguage: video.sourceLanguage,
            translations: video.translations,
            preference: contentLanguage,
            interfaceLocale: interfaceLocale
        ).text
    }

    private static func resolvePostSnippet(
        _ post: Post,
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) -> String {
        let raw = ContentLanguageResolver.resolve(
            original: post.text,
            sourceLanguage: post.sourceLanguage,
            translations: post.translations,
            preference: contentLanguage,
            interfaceLocale: interfaceLocale
        ).text
        let collapsed =
            raw
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        guard !collapsed.isEmpty else {
            return localized(.Notifications.bannerPostMediaFallback, locale: interfaceLocale)
        }
        guard collapsed.count > maxPostSnippetCharacters else {
            return collapsed
        }
        let end = collapsed.index(collapsed.startIndex, offsetBy: maxPostSnippetCharacters)
        return String(collapsed[..<end]) + "…"
    }

    private static func eventTimeSubtitle(_ event: ScheduleEvent, locale: Locale) -> String {
        JSTTimeFormat.entry(
            startsAt: event.startsAt,
            startsOn: event.startsOn,
            timePrecision: event.timePrecision,
            includesDate: true,
            locale: locale
        ) ?? ""
    }

    private static func localized(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var copy = resource
        copy.locale = locale
        return String(localized: copy)
    }
}
