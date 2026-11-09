import Foundation

public struct ScheduleMonthResult: Equatable, Sendable {
    public var dates: [JapanDate]
    public var events: [ScheduleEvent]
    public var dayCounts: [JapanDate: Int]
    public var adjacent: ArchiveAdjacent
    public var isStale: Bool
    public init(
        dates: [JapanDate], events: [ScheduleEvent], dayCounts: [JapanDate: Int],
        adjacent: ArchiveAdjacent, isStale: Bool
    ) {
        self.dates = dates
        self.events = events
        self.dayCounts = dayCounts
        self.adjacent = adjacent
        self.isStale = isStale
    }
}
