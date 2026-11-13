import Foundation

/// Last observed state and start time of a schedule entry in the notification baseline.
public struct RecordedEventSnapshot: Codable, Equatable, Sendable {
    public var state: EventState
    public var startsOn: JapanDate
    public var startsAt: Date?

    public init(state: EventState, startsOn: JapanDate, startsAt: Date?) {
        self.state = state
        self.startsOn = startsOn
        self.startsAt = startsAt
    }
}
