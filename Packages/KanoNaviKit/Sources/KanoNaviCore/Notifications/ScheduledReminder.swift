import Foundation

/// A local notification scheduled for a future `Date` via `UNCalendarNotificationTrigger`.
public struct ScheduledReminder: Equatable, Identifiable, Sendable {
    public var id: String
    public var triggerDate: Date
    public var route: NotificationRoute
    public var kind: ScheduledReminderKind

    public init(
        id: String,
        triggerDate: Date,
        route: NotificationRoute,
        kind: ScheduledReminderKind
    ) {
        self.id = id
        self.triggerDate = triggerDate
        self.route = route
        self.kind = kind
    }
}
