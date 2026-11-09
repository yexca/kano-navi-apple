import Foundation

public struct WidgetCalendarResult: Equatable, Sendable {
  public var events: [ScheduleEvent]
  public var calendarEntries: [CalendarEntryView]
  public var nextTransitionAt: Date?
  public var fetchedAt: Date?
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
