import Foundation
import Testing

@testable import KanoNaviCore

struct NotificationPlannerTests {
    private let now = KanoNaviDateCoding.date(from: "2026-11-10T09:00:00Z")!

    private func baseDashboardObject() throws -> [String: Any] {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func decodeDashboard(_ object: [String: Any]) throws -> Dashboard {
        let data = try JSONSerialization.data(withJSONObject: object)
        return try JSONDecoder.kanoNavi().decode(Dashboard.self, from: data)
    }

    private func postJSON(
        id: String,
        source: String = "x",
        publishedAt: String,
        text: String = "Update",
        promoted: Bool = false
    ) -> [String: Any] {
        [
            "id": id,
            "source": source,
            "accountHandle": source == "bilibili" ? NSNull() : "kano_synthetic",
            "accountUrl": "https://example.com/account",
            "publishedAt": publishedAt,
            "text": text,
            "url": "https://example.com/posts/\(id)",
            "media": [],
            "mediaUrl": NSNull(),
            "mediaStatus": "none",
            "promoted": promoted,
        ]
    }

    // swift-format-ignore: FunctionParameterCount
    private func videoJSON(
        id: String,
        url: String = "https://www.youtube.com/watch?v=vid1",
        publishedAt: String? = "2026-11-10T08:55:00Z",
        scheduledAt: String? = nil,
        phase: String = "past",
        formCode: String = "video",
        shelfGroup: String = "work",
        availability: String = "public"
    ) -> [String: Any] {
        [
            "id": id,
            "source": "youtube",
            "title": "Video \(id)",
            "publishedAt": publishedAt ?? NSNull(),
            "scheduledAt": scheduledAt ?? NSNull(),
            "endsAt": NSNull(),
            "url": url,
            "thumbnailUrl": NSNull(),
            "thumbnailStatus": "none",
            "kind": "video",
            "tag": "song",
            "isUpcoming": phase == "upcoming",
            "isCancelled": false,
            "liveStatus": phase == "live" ? "live" : "ended",
            "durationSeconds": 180,
            "isShort": formCode == "short",
            "availability": availability,
            "alternates": [],
            "view": [
                "phase": phase,
                "formCode": formCode,
                "shelfGroup": shelfGroup,
                "latestEligible": true,
                "focusEligible": false,
                "tagContext": shelfGroup == "work" ? "work" : "stream",
            ],
        ]
    }

    // swift-format-ignore: FunctionParameterCount
    private func eventJSON(
        id: String,
        title: String = "Event",
        startsOn: String = "2026-11-11",
        startsAt: String? = "2026-11-11T12:00:00Z",
        endsOn: String? = nil,
        timePrecision: String = "exact",
        state: String = "upcoming",
        typeCode: String = "stream",
        provenance: String = "automatic",
        url: String = "https://example.com/events/1",
        linkURL: String? = nil,
        entries: [[String: Any]]? = nil
    ) -> [String: Any] {
        let calendarEntries =
            entries ?? [
                [
                    "saleMark": NSNull(),
                    "startsOn": startsOn,
                    "startsAt": startsAt ?? NSNull(),
                    "timePrecision": timePrecision,
                ]
            ]
        var links: [[String: Any]] = []
        if let linkURL {
            links.append(["platform": "youtube", "url": linkURL, "liveStatus": "upcoming"])
        }
        return [
            "id": id,
            "source": "x",
            "platform": "youtube",
            "title": title,
            "detail": NSNull(),
            "startsOn": startsOn,
            "startsAt": startsAt ?? NSNull(),
            "endsAt": NSNull(),
            "endsOn": endsOn ?? NSNull(),
            "timezone": "Asia/Tokyo",
            "timePrecision": timePrecision,
            "status": "scheduled",
            "eventType": typeCode == "member" ? "member" : typeCode,
            "tag": "live",
            "url": url,
            "provenance": provenance,
            "manualLocked": provenance == "manual",
            "isUpcoming": state == "upcoming",
            "cancellationStatus": state == "cancelled" ? "confirmed" : "none",
            "liveStatus": state == "live" ? "live" : "upcoming",
            "platforms": ["youtube"],
            "links": links,
            "view": [
                "state": state,
                "typeCode": typeCode,
                "activityCode": "live",
                "activityContext": "stream",
                "isWork": typeCode == "release" || typeCode == "video",
                "calendarEntries": calendarEntries,
            ],
        ]
    }

    @Test func coldStartRecordsBaselineWithoutImmediateAlertsAndPlansReminders() throws {
        let dashboard = try decodeDashboard(baseDashboardObject())
        var preferences = NotificationPreferences(isEnabled: true)
        preferences.eventReminderLead = .tenMinutes

        let evaluation = NotificationPlanner.evaluate(
            dashboard: dashboard,
            baseline: nil,
            preferences: preferences,
            now: now
        )

        #expect(evaluation.immediate.isEmpty)
        #expect(evaluation.baseline.seenPostIDs == ["post-1"])
        #expect(evaluation.baseline.seenVideoShelfGroups["video-1"] == "work")
        #expect(evaluation.baseline.seenEvents["event-1"]?.state == .upcoming)
        #expect(evaluation.reminders.count == 1)
        let expectedTrigger = try #require(KanoNaviDateCoding.date(from: "2026-11-11T10:50:00Z"))
        #expect(evaluation.reminders.first?.triggerDate == expectedTrigger)
    }

    @Test func threePostSwitchesAndBackfillGuardFilterAccurately() throws {
        var object = try baseDashboardObject()
        let initial = try decodeDashboard(object)
        var preferences = NotificationPreferences(isEnabled: true)
        preferences.posts = PostNotificationSettings(
            ownXPosts: true,
            bilibiliPosts: false,
            promotedPosts: true
        )

        let seeded = NotificationPlanner.evaluate(
            dashboard: initial,
            baseline: nil,
            preferences: preferences,
            now: now
        )

        let later = now.addingTimeInterval(600)
        object["posts"] = [
            postJSON(id: "x-own", source: "x", publishedAt: "2026-11-10T09:05:00Z", promoted: false),
            postJSON(
                id: "bili-own", source: "bilibili", publishedAt: "2026-11-10T09:05:00Z", promoted: false),
            postJSON(id: "x-promo", source: "x", publishedAt: "2026-11-10T09:06:00Z", promoted: true),
            postJSON(id: "old-backfill", source: "x", publishedAt: "2026-11-01T00:00:00Z", promoted: false),
            postJSON(id: "post-1", source: "x", publishedAt: "2026-11-09T15:00:00Z", promoted: false),
        ]
        let updated = try decodeDashboard(object)
        let diff = NotificationPlanner.evaluate(
            dashboard: updated,
            baseline: seeded.baseline,
            preferences: preferences,
            now: later
        )

        #expect(diff.immediate.map(\.id) == ["kanonavi.post.x-own", "kanonavi.post.x-promo"])
        #expect(diff.baseline.seenPostIDs.contains("old-backfill"))
    }

    @Test func deduplicatesYouTubeReservationAgainstDerivedScheduleEventAndHandlesArchiveTransition() throws {
        var object = try baseDashboardObject()
        let initial = try decodeDashboard(object)
        var preferences = NotificationPreferences(isEnabled: true)
        preferences.videos = VideoNotificationSettings(works: true, shorts: true, archives: false)

        let seeded = NotificationPlanner.evaluate(
            dashboard: initial,
            baseline: nil,
            preferences: preferences,
            now: now
        )

        // New waiting room appears as both a reservation Video (youtube.com/watch?v=stream99)
        // and a derived ScheduleEvent (youtu.be/stream99). Only the schedule event should notify.
        object["events"] = [
            eventJSON(
                id: "event-stream99",
                startsOn: "2026-11-12",
                startsAt: "2026-11-12T12:00:00Z",
                url: "https://youtu.be/stream99"
            )
        ]
        object["videos"] = [
            videoJSON(
                id: "yt-stream99",
                url: "https://www.youtube.com/watch?v=stream99",
                publishedAt: nil,
                scheduledAt: "2026-11-12T12:00:00Z",
                phase: "upcoming",
                formCode: "upcoming",
                shelfGroup: "reservation"
            )
        ]

        let step1 = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: seeded.baseline,
            preferences: preferences,
            now: now.addingTimeInterval(60)
        )
        #expect(step1.immediate.map(\.id) == ["kanonavi.event.new.event-stream99"])

        // When the stream ends and becomes an archive: silent while archives == false.
        object["videos"] = [
            videoJSON(
                id: "yt-stream99",
                url: "https://www.youtube.com/watch?v=stream99",
                publishedAt: "2026-11-10T09:10:00Z",
                phase: "past",
                formCode: "archive",
                shelfGroup: "archive"
            )
        ]
        let silentArchive = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: step1.baseline,
            preferences: preferences,
            now: now.addingTimeInterval(600)
        )
        #expect(silentArchive.immediate.isEmpty)

        // With archives == true, transitioning from reservation -> archive emits an archive alert.
        preferences.videos.archives = true
        let loudArchive = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: step1.baseline,
            preferences: preferences,
            now: now.addingTimeInterval(600)
        )
        #expect(loudArchive.immediate.map(\.id) == ["kanonavi.video.archive.yt-stream99"])
    }

    @Test func coalescesPostBurstAboveThreeIntoTwoItemsPlusSummary() throws {
        var object = try baseDashboardObject()
        let preferences = NotificationPreferences(isEnabled: true)
        let seeded = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: nil,
            preferences: preferences,
            now: now
        )

        object["posts"] = (1...5).map { index in
            postJSON(id: "burst-\(index)", publishedAt: "2026-11-10T09:05:00Z")
        }
        let result = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: seeded.baseline,
            preferences: preferences,
            now: now.addingTimeInterval(600)
        )

        #expect(result.immediate.count == 3)
        #expect(result.immediate[0].id == "kanonavi.post.burst-1")
        #expect(result.immediate[1].id == "kanonavi.post.burst-2")
        #expect(result.immediate[2].kind == .summary(thread: .posts, additionalCount: 3))
    }

    @Test func detectsLiveTransitionsCancellationsReschedulesAndMembersFilter() throws {
        var object = try baseDashboardObject()
        object["events"] = [
            eventJSON(
                id: "ev-stream", startsOn: "2026-11-11", startsAt: "2026-11-11T12:00:00Z", state: "upcoming"),
            eventJSON(
                id: "ev-cancel", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z", state: "upcoming"),
            eventJSON(
                id: "ev-move", startsOn: "2026-11-13", startsAt: "2026-11-13T12:00:00Z", state: "upcoming"),
            eventJSON(
                id: "ev-member",
                startsOn: "2026-11-14",
                startsAt: "2026-11-14T12:00:00Z",
                state: "upcoming",
                typeCode: "member"
            ),
        ]
        var preferences = NotificationPreferences(isEnabled: true)
        preferences.includeMembersOnly = false

        let seeded = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: nil,
            preferences: preferences,
            now: now
        )

        object["liveNow"] = [
            "platform": "bilibili",
            "url": "https://live.example.com/1",
            "title": "Surprise Bilibili Stream",
            "startedAt": "2026-11-10T09:05:00Z",
        ]
        object["events"] = [
            eventJSON(
                id: "ev-stream", startsOn: "2026-11-11", startsAt: "2026-11-11T12:00:00Z", state: "live"),
            eventJSON(
                id: "ev-cancel", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z", state: "cancelled"),
            eventJSON(
                id: "ev-move", startsOn: "2026-11-13", startsAt: "2026-11-13T14:00:00Z", state: "upcoming"),
            eventJSON(
                id: "ev-member",
                startsOn: "2026-11-14",
                startsAt: "2026-11-14T12:00:00Z",
                state: "live",
                typeCode: "member"
            ),
        ]

        let diff = NotificationPlanner.evaluate(
            dashboard: try decodeDashboard(object),
            baseline: seeded.baseline,
            preferences: preferences,
            now: now.addingTimeInterval(600)
        )

        let ids = diff.immediate.map(\.id)
        #expect(ids.contains { $0.hasPrefix("kanonavi.live.unscheduled.") })
        #expect(ids.contains("kanonavi.live.event.ev-stream"))
        #expect(ids.contains("kanonavi.event.cancelled.ev-cancel"))
        #expect(ids.contains { $0.hasPrefix("kanonavi.event.rescheduled.ev-move.") })
        #expect(ids.contains("kanonavi.live.event.ev-member") == false)
    }

    @Test func plansTimedAndDateOnlyMerchandiseSaleOpenAndCloseReminders() throws {
        var object = try baseDashboardObject()
        object["events"] = [
            eventJSON(
                id: "sale-timed",
                title: "Timed Merch",
                startsOn: "2026-11-11",
                startsAt: "2026-11-11T03:00:00Z",
                endsOn: "2026-11-15",
                state: "upcoming",
                typeCode: "sale",
                entries: [
                    [
                        "saleMark": "opens",
                        "startsOn": "2026-11-11",
                        "startsAt": "2026-11-11T03:00:00Z",
                        "timePrecision": "exact",
                    ],
                    [
                        "saleMark": "closes",
                        "startsOn": "2026-11-15",
                        "startsAt": "2026-11-15T14:59:00Z",
                        "timePrecision": "exact",
                    ],
                ]
            ),
            eventJSON(
                id: "sale-date-only",
                title: "Date Only Merch",
                startsOn: "2026-11-12",
                startsAt: nil,
                endsOn: "2026-11-20",
                timePrecision: "unknown",
                state: "upcoming",
                typeCode: "sale",
                entries: [
                    [
                        "saleMark": "opens",
                        "startsOn": "2026-11-12",
                        "startsAt": NSNull(),
                        "timePrecision": "unknown",
                    ],
                    [
                        "saleMark": "closes",
                        "startsOn": "2026-11-20",
                        "startsAt": NSNull(),
                        "timePrecision": "unknown",
                    ],
                ]
            ),
        ]

        var preferences = NotificationPreferences(isEnabled: true)
        preferences.notifySaleOpens = true
        preferences.saleCloseLead = .twentyFourHours

        let dashboard = try decodeDashboard(object)
        let reminders = NotificationPlanner.planReminders(
            events: dashboard.events,
            preferences: preferences,
            now: now
        )

        #expect(reminders.count == 4)

        let byID = Dictionary(uniqueKeysWithValues: reminders.map { ($0.id, $0) })
        #expect(
            byID["kanonavi.reminder.sale.open.sale-timed"]?.triggerDate
                == KanoNaviDateCoding.date(from: "2026-11-11T03:00:00Z")
        )
        #expect(
            byID["kanonavi.reminder.sale.close.sale-timed.twentyFourHours"]?.triggerDate
                == KanoNaviDateCoding.date(from: "2026-11-14T14:59:00Z")
        )
        // 09:00 JST on 2026-11-12 is 2026-11-12T00:00:00Z.
        #expect(
            byID["kanonavi.reminder.sale.open.sale-date-only"]?.triggerDate
                == KanoNaviDateCoding.date(from: "2026-11-12T00:00:00Z")
        )
        // 24h lead on date-only close 2026-11-20 fires at 09:00 JST on 2026-11-19 (2026-11-19T00:00:00Z).
        #expect(
            byID["kanonavi.reminder.sale.close.sale-date-only.twentyFourHours"]?.triggerDate
                == KanoNaviDateCoding.date(from: "2026-11-19T00:00:00Z")
        )
    }

    @Test func fileStateStoreRoundTripsBaseline() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = FileNotificationStateStore(
            fileURL: directory.appendingPathComponent("baseline.json")
        )
        var baseline = NotificationBaseline(establishedAt: now, lastRevision: 7, lastLiveNowKey: "key-1")
        baseline.recordPost("p-1")
        baseline.recordVideo("v-1", shelfGroup: "work")
        baseline.recordEvent(
            "e-1",
            snapshot: RecordedEventSnapshot(
                state: .upcoming,
                startsOn: JapanDate(year: 2026, month: 11, day: 14),
                startsAt: now
            )
        )

        await store.save(baseline)
        let loaded = await store.load()
        #expect(loaded == baseline)

        await store.clear()
        #expect(await store.load() == nil)
    }
}
