import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct AppRouterTests {
    @Test func eventLinkFocusesTheEntry() throws {
        let url = try #require(URL(string: "kanonavi://event/youtube-abc123"))

        #expect(AppRouter.scheduleFocus(for: url) == .event(id: "youtube-abc123"))
    }

    @Test func scheduleLinkFocusesTheDate() throws {
        let url = try #require(URL(string: "kanonavi://schedule?date=2026-11-12"))

        #expect(AppRouter.scheduleFocus(for: url) == .date(JapanDate(year: 2026, month: 11, day: 12)))
    }

    @Test func scheduleLinkWithoutValidDateFocusesToday() throws {
        let url = try #require(URL(string: "kanonavi://schedule?date=2026-13-40"))

        #expect(AppRouter.scheduleFocus(for: url) == .date(.today))
    }

    @Test(arguments: ["https://example.com/event/1", "kanonavi://event", "kanonavi://unknown/1"])
    func otherLinksAreIgnored(rawURL: String) throws {
        let url = try #require(URL(string: rawURL))
        let router = AppRouter()

        #expect(router.open(url) == false)
        #expect(router.selectedTab == .now)
        #expect(router.scheduleFocus == nil)
        #expect(router.moreDestination == nil)
    }

    @Test func openingALinkSelectsSchedule() throws {
        let url = try #require(URL(string: "kanonavi://event/synthetic-1"))
        let router = AppRouter()

        #expect(router.open(url))
        #expect(router.selectedTab == .schedule)
        #expect(router.scheduleFocus == .event(id: "synthetic-1"))
    }

    @Test func openingNotificationTabAndSettingsRoutes() throws {
        let router = AppRouter()

        #expect(router.open(try #require(URL(string: "kanonavi://posts"))))
        #expect(router.selectedTab == .posts)

        #expect(router.open(try #require(URL(string: "kanonavi://videos"))))
        #expect(router.selectedTab == .videos)

        #expect(router.open(try #require(URL(string: "kanonavi://now"))))
        #expect(router.selectedTab == .now)

        #expect(router.open(try #require(URL(string: "kanonavi://settings/notifications"))))
        #expect(router.selectedTab == .more)
        #expect(router.moreDestination == .notifications)
    }
}
