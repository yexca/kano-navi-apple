import Foundation
import KanoNaviCore
import Observation

/// The selected tab and pending deep-link targets.
///
/// Widgets and local notifications open `kanonavi://` URLs targeting tabs,
/// schedule entries or dates, and the notification settings screen.
@Observable
final class AppRouter {
    var selectedTab = AppTab.now
    var scheduleFocus: ScheduleFocus?
    var moreDestination: MoreDestination?
    /// The route a launch opened before its first frame. SwiftUI or the
    /// notification delegate delivers it again afterwards; that one delivery
    /// is skipped, so a focus is not applied twice.
    @ObservationIgnored private var launchRoute: NotificationRoute?

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
            selectedTab = .more
            moreDestination = .notifications
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
