import Foundation
import KanoNaviCore

/// Where a launch opens, read from what the system hands a connecting scene
/// before anything is drawn.
nonisolated enum LaunchRoute {
    /// The route of the notification tapped to launch the app, otherwise of
    /// the first `kanonavi://` URL opened with it (a widget tap or a link);
    /// `nil` for a plain launch.
    static func route(openedURLs: [URL], notificationUserInfo: [AnyHashable: Any]?) -> NotificationRoute? {
        if let notificationUserInfo, let route = NotificationRoute(userInfo: notificationUserInfo) {
            return route
        }
        return openedURLs.lazy.compactMap { NotificationRoute(url: $0) }.first
    }
}
