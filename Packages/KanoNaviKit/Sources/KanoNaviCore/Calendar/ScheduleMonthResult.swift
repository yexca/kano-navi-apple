import Foundation

public struct ScheduleMonthResult: Equatable, Sendable {
    public var dates: [JapanDate]
    public var events: [ScheduleEvent]
    public var dayCounts: [JapanDate: Int]
    public var adjacent: ArchiveAdjacent
    /// `true` when the service could not be read and the month comes from
    /// the cache.
    public var isStale: Bool
    /// When the month's data was fetched from the service; see
    /// `CalendarReadResult.fetchedAt`. `nil` only for values built without one.
    public var fetchedAt: Date?
    public init(
        dates: [JapanDate], events: [ScheduleEvent], dayCounts: [JapanDate: Int],
        adjacent: ArchiveAdjacent, isStale: Bool, fetchedAt: Date? = nil
    ) {
        self.dates = dates
        self.events = events
        self.dayCounts = dayCounts
        self.adjacent = adjacent
        self.isStale = isStale
        self.fetchedAt = fetchedAt
    }
}
