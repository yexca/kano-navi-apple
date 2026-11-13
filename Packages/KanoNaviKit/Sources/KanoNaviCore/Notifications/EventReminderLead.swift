import Foundation

/// How far ahead of a scheduled start to fire a local reminder.
public enum EventReminderLead: String, CaseIterable, Codable, Hashable, Sendable {
    case off
    case atStart
    case tenMinutes
    case thirtyMinutes

    public var offsetSeconds: TimeInterval? {
        switch self {
        case .off: nil
        case .atStart: 0
        case .tenMinutes: 10 * 60
        case .thirtyMinutes: 30 * 60
        }
    }
}
