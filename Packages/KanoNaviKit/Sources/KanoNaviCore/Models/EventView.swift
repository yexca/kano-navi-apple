import Foundation

public struct EventView: Codable, Equatable, Sendable {
    public var state: EventState
    public var typeCode: String?
    public var activityCode: String?
    public var activityContext: String
    public var isWork: Bool
    public var calendarEntries: [CalendarEntryView]
    public init(
        state: EventState, typeCode: String?, activityCode: String?, activityContext: String,
        isWork: Bool, calendarEntries: [CalendarEntryView]
    ) {
        self.state = state
        self.typeCode = typeCode
        self.activityCode = activityCode
        self.activityContext = activityContext
        self.isWork = isWork
        self.calendarEntries = calendarEntries
    }
}
