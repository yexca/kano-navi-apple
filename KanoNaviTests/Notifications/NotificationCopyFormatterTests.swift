import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NotificationCopyFormatterTests {
    @Test func formatsEventReminderInJSTAndChosenContentLanguage() throws {
        var eventJSON = DashboardFixture.event(
            id: "ev-song",
            title: "歌枠配信",
            startsOn: "2026-11-14",
            startsAt: "2026-11-14T12:00:00Z"
        )
        eventJSON["sourceLanguage"] = "ja"
        eventJSON["translations"] = [
            "en": ["text": "Singing Stream", "origin": "manual"],
            "zh-CN": ["text": "歌回直播", "origin": "manual"],
        ]
        eventJSON["timePrecision"] = "exact"

        let dashboard = try DashboardFixture(events: [eventJSON]).dashboard()
        let event = try #require(dashboard.events.first)
        let startsAt = try DashboardFixture.instant("2026-11-14T12:00:00Z")
        let reminder = ScheduledReminder(
            id: "kanonavi.reminder.event.ev-song.tenMinutes",
            triggerDate: startsAt.addingTimeInterval(-600),
            route: .event(id: "ev-song"),
            kind: .eventStart(event: event, lead: .tenMinutes, startsAt: startsAt)
        )

        let zhPayload = NotificationCopyFormatter.format(
            reminder,
            contentLanguage: .zhHans,
            interfaceLocale: Locale(identifier: "zh-Hans")
        )
        #expect(zhPayload.title == "10 分钟后开始")
        #expect(zhPayload.subtitle.contains("21:00"))
        #expect(zhPayload.subtitle.contains("JST"))
        #expect(zhPayload.body == "歌回直播")
        #expect(zhPayload.routeURL.absoluteString == "kanonavi://event/ev-song")
    }

    @Test func formatsEmptyTextBilibiliPostWithLocalizedFallback() throws {
        let postJSON: [String: Any] = [
            "id": "bili-empty",
            "source": "bilibili",
            "accountHandle": NSNull(),
            "publishedAt": "2026-11-14T10:00:00Z",
            "text": "",
            "url": "https://example.com/bili/1",
            "media": [],
            "mediaStatus": "none",
        ]
        let dashboard = try DashboardFixture(posts: [postJSON]).dashboard()
        let post = try #require(dashboard.posts.first)
        let planned = PlannedNotification(
            id: "kanonavi.post.bili-empty",
            thread: .posts,
            route: .posts,
            kind: .newPost(post)
        )

        let jaPayload = NotificationCopyFormatter.format(
            planned,
            contentLanguage: .ja,
            interfaceLocale: Locale(identifier: "ja")
        )
        #expect(jaPayload.title == "新しい Bilibili 動態")
        #expect(jaPayload.subtitle.isEmpty)
        #expect(jaPayload.body == "新しい投稿が公開されました。")
    }
}
