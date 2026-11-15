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
        #expect(router.stackRequest == nil)
    }

    @Test func openingALinkSelectsSchedule() throws {
        let url = try #require(URL(string: "kanonavi://event/synthetic-1"))
        let router = AppRouter()

        #expect(router.open(url))
        #expect(router.selectedTab == .schedule)
        #expect(router.scheduleFocus == .event(id: "synthetic-1"))
    }

    @Test func launchRouteIsAppliedOnceAndItsLaterDeliveryIsSkipped() throws {
        let url = try #require(URL(string: "kanonavi://event/synthetic-1"))
        let router = AppRouter()

        router.openAtLaunch(.event(id: "synthetic-1"))
        #expect(router.selectedTab == .schedule)
        #expect(router.scheduleFocus == .event(id: "synthetic-1"))

        // The person moves on before SwiftUI hands over the same link.
        router.selectedTab = .now
        router.scheduleFocus = nil
        #expect(router.open(url))
        #expect(router.selectedTab == .now)
        #expect(router.scheduleFocus == nil)

        // A later tap on the same link is applied.
        #expect(router.open(url))
        #expect(router.selectedTab == .schedule)
    }

    @Test func anotherRouteAfterLaunchIsApplied() {
        let router = AppRouter()
        router.openAtLaunch(.posts)

        router.open(.videos)

        #expect(router.selectedTab == .videos)
    }

    @Test func forgottenLaunchRouteIsAppliedAgain() {
        let router = AppRouter()
        router.openAtLaunch(.posts)
        router.selectedTab = .now
        router.forgetLaunchRoute()

        router.open(.posts)

        #expect(router.selectedTab == .posts)
    }

    @Test func openingNotificationTabAndSettingsRoutes() throws {
        let router = AppRouter(showsSidebar: false)

        #expect(router.open(try #require(URL(string: "kanonavi://posts"))))
        #expect(router.selectedTab == .posts)

        #expect(router.open(try #require(URL(string: "kanonavi://videos"))))
        #expect(router.selectedTab == .videos)

        #expect(router.open(try #require(URL(string: "kanonavi://now"))))
        #expect(router.selectedTab == .now)

        #expect(router.open(try #require(URL(string: "kanonavi://settings/notifications"))))
        #expect(router.selectedTab == .more)
        #expect(router.stackRequest == StackRequest(tab: .more, path: [.settings, .notifications]))
    }

    @Test func notificationSettingsInASidebarOpenTheSettingsTab() {
        let router = AppRouter(showsSidebar: true)

        router.open(.notificationSettings)

        #expect(router.selectedTab == .settings)
        #expect(router.stackRequest == StackRequest(tab: .settings, path: [.notifications]))
    }

    @Test func notificationSettingsWithAppWindowsAskForTheSettingsWindow() {
        let router = AppRouter(showsSidebar: true, usesAppWindows: true)
        router.selectedTab = .posts

        router.open(.notificationSettings)

        #expect(router.settingsWindowRequested)
        #expect(router.settingsPane == .notifications)
        #expect(router.selectedTab == .posts)
        #expect(router.stackRequest == nil)
    }

    @Test func settingsWithAppWindowsOpenTheGeneralPane() {
        let router = AppRouter(showsSidebar: true, usesAppWindows: true)
        router.settingsPane = .notifications

        router.show([.settings])

        #expect(router.settingsWindowRequested)
        #expect(router.settingsPane == .general)
    }

    @Test(arguments: [false, true])
    func aLinkWaitsForThePresentation(showsSidebar: Bool) {
        let router = AppRouter()
        router.openAtLaunch(.notificationSettings)
        #expect(router.selectedTab == .now)
        #expect(router.stackRequest == nil)

        router.tabPresentationChanged(showsSidebar: showsSidebar)

        if showsSidebar {
            #expect(router.selectedTab == .settings)
            #expect(router.stackRequest == StackRequest(tab: .settings, path: [.notifications]))
        } else {
            #expect(router.selectedTab == .more)
            #expect(router.stackRequest == StackRequest(tab: .more, path: [.settings, .notifications]))
        }
    }

    @Test(arguments: [
        (AppTab.journey, MoreDestination.journey), (.works, .works), (.lineBlog, .lineBlog),
        (.settings, .settings), (.about, .about),
    ])
    func aSidebarTabMovesToMoreInATabBar(tab: AppTab, screen: MoreDestination) {
        let router = AppRouter(showsSidebar: true)
        router.selectedTab = tab

        router.tabPresentationChanged(showsSidebar: false)

        #expect(router.selectedTab == .more)
        #expect(router.stackRequest == StackRequest(tab: .more, path: [screen]))
        #expect(router.moreRoot == screen)
    }

    @Test func moreMovesToTheTabOfItsScreenInASidebar() {
        let router = AppRouter(showsSidebar: false)
        router.selectedTab = .more
        router.moreRoot = .works

        router.tabPresentationChanged(showsSidebar: true)

        #expect(router.selectedTab == .works)
        #expect(router.stackRequest == StackRequest(tab: .works, path: []))
        #expect(router.moreRoot == nil)
    }

    @Test func moreShowingItsListMovesToJourneyInASidebar() {
        let router = AppRouter(showsSidebar: false)
        router.selectedTab = .more

        router.tabPresentationChanged(showsSidebar: true)

        #expect(router.selectedTab == .journey)
    }

    @Test(arguments: [AppTab.now, .schedule, .posts, .videos])
    func tabsBothPresentationsShowStaySelected(tab: AppTab) {
        let router = AppRouter(showsSidebar: false)
        router.selectedTab = tab

        router.tabPresentationChanged(showsSidebar: true)
        #expect(router.selectedTab == tab)
        router.tabPresentationChanged(showsSidebar: false)
        #expect(router.selectedTab == tab)
        #expect(router.stackRequest == nil)
    }

    @Test func anUnchangedPresentationLeavesTheSelection() {
        let router = AppRouter(showsSidebar: true)
        router.selectedTab = .journey

        router.tabPresentationChanged(showsSidebar: true)

        #expect(router.selectedTab == .journey)
        #expect(router.stackRequest == nil)
    }
}
