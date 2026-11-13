import Foundation

/// High-level schedule entry kinds used to filter schedule notifications.
public enum ScheduleNotificationCategory: String, CaseIterable, Codable, Hashable, Sendable {
    case stream
    case event
    case release
    case sale
}
