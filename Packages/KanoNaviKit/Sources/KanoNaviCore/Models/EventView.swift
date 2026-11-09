import Foundation

public enum EventState: Codable, Equatable, Sendable { case upcoming, live, open, done, pending, cancelled, cancellationReview, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "upcoming": .upcoming; case "live": .live; case "open": .open; case "done": .done; case "pending": .pending; case "cancelled": .cancelled; case "cancellation_review": .cancellationReview; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .upcoming:"upcoming"; case .live:"live"; case .open:"open"; case .done:"done"; case .pending:"pending"; case .cancelled:"cancelled"; case .cancellationReview:"cancellation_review"; case .unknown(let v):v } }
}

public struct CalendarEntryView: Codable, Equatable, Sendable {
    public var saleMark: SaleMark?
    public var startsOn: JapanDate
    public var startsAt: Date?
    public var timePrecision: String
    public init(saleMark: SaleMark? = nil, startsOn: JapanDate, startsAt: Date? = nil, timePrecision: String) { self.saleMark = saleMark; self.startsOn = startsOn; self.startsAt = startsAt; self.timePrecision = timePrecision }
}

public struct EventView: Codable, Equatable, Sendable {
    public var state: EventState
    public var typeCode: String?
    public var activityCode: String?
    public var activityContext: String
    public var isWork: Bool
    public var calendarEntries: [CalendarEntryView]
    public init(state: EventState, typeCode: String?, activityCode: String?, activityContext: String, isWork: Bool, calendarEntries: [CalendarEntryView]) { self.state = state; self.typeCode = typeCode; self.activityCode = activityCode; self.activityContext = activityContext; self.isWork = isWork; self.calendarEntries = calendarEntries }
}
