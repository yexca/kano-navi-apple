import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The target a launch opens, from what the system hands a connecting scene.
struct LaunchRouteTests {
    private func url(_ raw: String) throws -> URL {
        try #require(URL(string: raw))
    }

    @Test func plainLaunchHasNoRoute() {
        #expect(LaunchRoute.route(openedURLs: [], notificationUserInfo: nil) == nil)
    }

    @Test func widgetOrLinkOpensItsRoute() throws {
        let route = LaunchRoute.route(
            openedURLs: [try url("kanonavi://schedule?date=2026-11-12")], notificationUserInfo: nil)

        #expect(route == .schedule(date: JapanDate(year: 2026, month: 11, day: 12)))
    }

    @Test func firstKanoNaviURLWins() throws {
        let route = LaunchRoute.route(
            openedURLs: [
                try url("https://example.com/videos"), try url("kanonavi://videos"),
                try url("kanonavi://posts"),
            ],
            notificationUserInfo: nil)

        #expect(route == .videos)
    }

    @Test func tappedNotificationOpensItsRoute() {
        let info: [AnyHashable: Any] = [NotificationUserInfoKey.routeURL: "kanonavi://event/youtube-SYNTH01"]

        #expect(
            LaunchRoute.route(openedURLs: [], notificationUserInfo: info) == .event(id: "youtube-SYNTH01"))
    }

    @Test func notificationWinsOverAURL() throws {
        let info: [AnyHashable: Any] = [NotificationUserInfoKey.routeURL: "kanonavi://posts"]

        #expect(
            LaunchRoute.route(openedURLs: [try url("kanonavi://videos")], notificationUserInfo: info)
                == .posts)
    }

    @Test(arguments: ["https://example.com/posts", "kanonavi://unknown", ""])
    func notificationWithoutAKnownRouteFallsBackToTheURL(routeURL: String) throws {
        let info: [AnyHashable: Any] = [NotificationUserInfoKey.routeURL: routeURL]

        #expect(
            LaunchRoute.route(openedURLs: [try url("kanonavi://videos")], notificationUserInfo: info)
                == .videos)
    }

    @Test func notificationWithoutARouteKeyFallsBackToTheURL() throws {
        let info: [AnyHashable: Any] = ["other": "kanonavi://posts", NotificationUserInfoKey.routeURL: 42]

        #expect(
            LaunchRoute.route(openedURLs: [try url("kanonavi://videos")], notificationUserInfo: info)
                == .videos)
    }
}
