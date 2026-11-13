/// OS notification authorization state mapped to a Sendable Swift value.
nonisolated enum NotificationAuthorizationState: Equatable, Sendable {
    case notDetermined
    case authorized
    case provisional
    case denied

    var canDeliverNotifications: Bool {
        self == .authorized || self == .provisional
    }
}
