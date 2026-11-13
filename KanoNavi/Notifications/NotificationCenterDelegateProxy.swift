import Foundation
import KanoNaviCore
import UserNotifications

/// Forwards `UNUserNotificationCenterDelegate` callbacks onto `@MainActor`
/// without crossing actor boundaries with non-Sendable notification objects.
nonisolated final class NotificationCenterDelegateProxy: NSObject, UNUserNotificationCenterDelegate, Sendable
{
    private let onOpenRoute: @MainActor @Sendable (NotificationRoute) -> Void

    init(onOpenRoute: @escaping @MainActor @Sendable (NotificationRoute) -> Void) {
        self.onOpenRoute = onOpenRoute
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let isTimedReminder =
            notification.request.content.threadIdentifier == NotificationThread.reminders.rawValue
        if isTimedReminder {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let rawURL =
            response.notification.request.content.userInfo[NotificationUserInfoKey.routeURL] as? String
        completionHandler()
        guard let rawURL, let url = URL(string: rawURL), let route = NotificationRoute(url: url) else {
            return
        }
        let handler = onOpenRoute
        Task { @MainActor in
            handler(route)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        let handler = onOpenRoute
        Task { @MainActor in
            handler(.notificationSettings)
        }
    }
}
