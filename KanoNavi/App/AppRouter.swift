import Foundation
import KanoNaviCore
import Observation

/// The selected tab and pending deep-link targets.
///
/// Widgets and local notifications open `kanonavi://` URLs targeting tabs,
/// schedule entries or dates, and the notification settings screen.
///
/// A tab bar reaches Journey, Works, LINE BLOG, Settings and About through
/// More; a sidebar lists them as tabs of their own and hides More. An iPad
/// switches between the two while the app runs, and SwiftUI then leaves a
/// tab the new presentation does not list selected with nothing highlighted.
/// So the router follows the presentation the tabs report and moves the selection
/// to the same screen in the new one: a sidebar tab to More opened at its
/// screen, and More to the sidebar tab of the screen it shows (Journey when
/// it shows its list). Only the root screen carries over, not deeper pushes.
@Observable
final class AppRouter {
    var selectedTab = AppTab.now
    var scheduleFocus: ScheduleFocus?
    /// A path one tab's stack shows next; that stack takes it and clears it.
    var stackRequest: StackRequest?
    /// Whether the tab view shows a sidebar rather than a tab bar; `nil`
    /// until a tab reports it.
    private(set) var showsSidebar: Bool?
    /// The screen More shows at its root, `nil` while it shows its list.
    @ObservationIgnored var moreRoot: MoreDestination?
    /// More screens to show once the presentation is known.
    @ObservationIgnored private var pendingPath: [MoreDestination]?
    /// The route a launch opened before its first frame. SwiftUI or the
    /// notification delegate delivers it again afterwards; that one delivery
    /// is skipped, so a focus is not applied twice.
    @ObservationIgnored private var launchRoute: NotificationRoute?

    /// - Parameter showsSidebar: The presentation, where the platform fixes
    ///   it; otherwise the tabs report it once drawn.
    init(showsSidebar: Bool? = nil) {
        self.showsSidebar = showsSidebar
    }

    /// Applies a `kanonavi://` URL. Returns `false` for any other URL.
    @discardableResult
    func open(_ url: URL) -> Bool {
        guard let route = NotificationRoute(url: url) else { return false }
        open(route)
        return true
    }

    /// Applies the route a launch asks for, before the first frame, and
    /// skips its later delivery once.
    func openAtLaunch(_ route: NotificationRoute) {
        launchRoute = nil
        open(route)
        launchRoute = route
    }

    /// Stops waiting for the launch route's later delivery, once the app
    /// leaves the screen, so a later tap on the same target is applied.
    func forgetLaunchRoute() {
        launchRoute = nil
    }

    func open(_ route: NotificationRoute) {
        if let launchRoute, launchRoute == route {
            self.launchRoute = nil
            return
        }
        switch route {
        case .now:
            selectedTab = .now
        case .posts:
            selectedTab = .posts
        case .videos:
            selectedTab = .videos
        case .event(let id):
            selectedTab = .schedule
            scheduleFocus = .event(id: id)
        case .schedule(let date):
            selectedTab = .schedule
            scheduleFocus = .date(date)
        case .notificationSettings:
            show([.settings, .notifications])
        }
    }

    /// Shows More's screens `path`, first to last: in a sidebar on the tab
    /// with the first one at its root, in a tab bar on More. Before the
    /// presentation is known it waits for it.
    func show(_ path: [MoreDestination]) {
        guard let root = path.first else { return }
        guard let showsSidebar else {
            pendingPath = path
            return
        }
        pendingPath = nil
        if showsSidebar, let tab = AppTab(sidebarRoot: root) {
            moreRoot = nil
            selectedTab = tab
            stackRequest = StackRequest(tab: tab, path: Array(path.dropFirst()))
        } else {
            selectedTab = .more
            stackRequest = StackRequest(tab: .more, path: path)
            moreRoot = root
        }
    }

    /// Records the presentation a tab reports and moves a selection it hides
    /// to the same screen in it.
    func tabPresentationChanged(showsSidebar: Bool) {
        guard showsSidebar != self.showsSidebar else { return }
        self.showsSidebar = showsSidebar
        if let pendingPath {
            show(pendingPath)
        } else if showsSidebar, selectedTab == .more {
            show([moreRoot ?? .journey])
        } else if !showsSidebar, let root = selectedTab.moreDestination {
            show([root])
        }
    }

    /// The schedule target a `kanonavi://` URL names, if any. A schedule link
    /// without a valid date focuses today's Japan date.
    static func scheduleFocus(for url: URL) -> ScheduleFocus? {
        switch NotificationRoute(url: url) {
        case .event(let id):
            .event(id: id)
        case .schedule(let date):
            .date(date)
        default:
            nil
        }
    }
}
