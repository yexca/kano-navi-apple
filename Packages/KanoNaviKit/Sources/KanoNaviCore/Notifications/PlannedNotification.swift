import Foundation

/// An immediate local notification to deliver after a snapshot diff.
public struct PlannedNotification: Equatable, Identifiable, Sendable {
    public var id: String
    public var thread: NotificationThread
    public var route: NotificationRoute
    public var kind: PlannedNotificationKind

    public init(
        id: String,
        thread: NotificationThread,
        route: NotificationRoute,
        kind: PlannedNotificationKind
    ) {
        self.id = id
        self.thread = thread
        self.route = route
        self.kind = kind
    }
}
