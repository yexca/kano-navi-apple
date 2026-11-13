import Foundation
import Testing

@testable import KanoNaviCore

struct NotificationRouteTests {
    @Test(arguments: [
        NotificationRoute.now,
        .posts,
        .videos,
        .event(id: "youtube-abc_123"),
        .schedule(date: JapanDate(year: 2026, month: 11, day: 14)),
        .notificationSettings,
    ])
    func routesRoundTripThroughURL(route: NotificationRoute) {
        let parsed = NotificationRoute(url: route.url)
        #expect(parsed == route)
    }

    @Test func scheduleWithoutValidDateFallsBackToDefaultDate() throws {
        let fallback = JapanDate(year: 2026, month: 11, day: 14)
        let url = try #require(URL(string: "kanonavi://schedule?date=2026-99-99"))
        #expect(NotificationRoute(url: url, defaultDate: fallback) == .schedule(date: fallback))
    }

    @Test(arguments: [
        "https://example.com/now",
        "kanonavi://event",
        "kanonavi://unknown/1",
        "kanonavi://settings",
        "kanonavi://settings/other",
        "kanonavi://posts/extra",
    ])
    func rejectsUnsupportedURLs(raw: String) throws {
        let url = try #require(URL(string: raw))
        #expect(NotificationRoute(url: url) == nil)
    }
}
