import Foundation
import KanoNaviCore
import UserNotifications

/// Production `UNUserNotificationCenter` adapter keeping Objective-C notification
/// objects inside nonisolated methods.
nonisolated struct SystemUserNotificationCenterClient: UserNotificationCenterClient {
    func authorizationState() async -> NotificationAuthorizationState {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: Self.map(settings.authorizationStatus))
            }
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .providesAppNotificationSettings]
        )
    }

    func add(_ payload: LocalNotificationPayload) async throws {
        let content = UNMutableNotificationContent()
        content.title = payload.title
        if !payload.subtitle.isEmpty {
            content.subtitle = payload.subtitle
        }
        content.body = payload.body
        content.sound = .default
        content.threadIdentifier = payload.threadIdentifier
        content.userInfo = [NotificationUserInfoKey.routeURL: payload.routeURL.absoluteString]

        let trigger: UNNotificationTrigger?
        if let triggerDate = payload.triggerDate {
            trigger = Self.calendarTrigger(for: triggerDate)
        } else {
            trigger = nil
        }

        let request = UNNotificationRequest(
            identifier: payload.id,
            content: content,
            trigger: trigger
        )
        try await UNUserNotificationCenter.current().add(request)
    }

    func pendingRequestIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                continuation.resume(returning: requests.map(\.identifier))
            }
        }
    }

    func removePendingRequests(withIdentifiers identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    static func calendarTrigger(for instant: Date) -> UNCalendarNotificationTrigger {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = JapanDate.timeZone
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: instant
        )
        components.calendar = calendar
        components.timeZone = JapanDate.timeZone
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    private static func map(_ status: UNAuthorizationStatus) -> NotificationAuthorizationState {
        switch status {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized, .ephemeral:
            .authorized
        case .provisional:
            .provisional
        @unknown default:
            .notDetermined
        }
    }
}
