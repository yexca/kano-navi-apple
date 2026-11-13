import Foundation

/// A local notification ready to hand to `UNUserNotificationCenter`.
nonisolated struct LocalNotificationPayload: Equatable, Identifiable, Sendable {
    var id: String
    var title: String
    var subtitle: String
    var body: String
    var threadIdentifier: String
    var routeURL: URL
    /// `nil` delivers immediately; a future `Date` schedules a `UNCalendarNotificationTrigger`.
    var triggerDate: Date?
}
