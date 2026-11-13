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

    /// Applies a `kanonavi://` URL. Returns `false` for any other URL.
    @discardableResult
    func open(_ url: URL) -> Bool {
        guard let route = NotificationRoute(url: url) else { return false }
        open(route)
        return true
    }

    func open(_ route: NotificationRoute) {
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
