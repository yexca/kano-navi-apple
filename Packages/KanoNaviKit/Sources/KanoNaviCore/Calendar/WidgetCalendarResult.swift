import Foundation

public struct WidgetCalendarResult: Equatable, Sendable {
    public var events: [ScheduleEvent]
    public var calendarEntries: [CalendarEntryView]
    public var nextTransitionAt: Date?
    /// When the range's data was fetched from the service; see
    /// `CalendarReadResult.fetchedAt`.
    public var fetchedAt: Date?
    /// `true` when the service could not be read and the range comes from
    /// the cache.
    public var isStale: Bool
    public init(
        events: [ScheduleEvent], calendarEntries: [CalendarEntryView], nextTransitionAt: Date?,
        fetchedAt: Date?, isStale: Bool
    ) {
        self.events = events
        self.calendarEntries = calendarEntries
        self.nextTransitionAt = nextTransitionAt
        self.fetchedAt = fetchedAt
        self.isStale = isStale
    }
}
