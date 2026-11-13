import Foundation

/// How far ahead of a merchandise sale's closing time to fire a local reminder.
public enum SaleCloseReminderLead: String, CaseIterable, Codable, Hashable, Sendable {
    case off
    case oneHour
    case sixHours
    case twentyFourHours

    public var offsetSeconds: TimeInterval? {
        switch self {
        case .off: nil
        case .oneHour: 60 * 60
        case .sixHours: 6 * 60 * 60
        case .twentyFourHours: 24 * 60 * 60
        }
    }
}
