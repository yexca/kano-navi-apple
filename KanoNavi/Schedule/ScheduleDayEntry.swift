import Foundation
import KanoNaviComponents
import KanoNaviCore

/// One calendar entry of one event on a Japan date. A sale appears twice in
/// the calendar, once where it opens and once where it closes.
nonisolated struct ScheduleDayEntry: Identifiable, Equatable {
    let event: ScheduleEvent
    let entry: CalendarEntryView
    let id: String

    /// The entries on `date`, in server order, then by start: date-only
    /// entries first, then by time.
    static func entries(on date: JapanDate, in events: [ScheduleEvent]) -> [ScheduleDayEntry] {
        let entries = events.flatMap { event in
            event.displayCalendarEntries.enumerated().compactMap { index, entry in
                entry.startsOn == date
                    ? ScheduleDayEntry(event: event, entry: entry, id: "\(event.id)#\(index)") : nil
            }
        }
        return entries.enumerated()
            .sorted { lhs, rhs in
                let left = lhs.element.sortTime
                let right = rhs.element.sortTime
                return left == right ? lhs.offset < rhs.offset : left < right
            }
            .map(\.element)
    }

    private var sortTime: Date {
        if let startsAt = entry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: entry.timePrecision)
        {
            return startsAt
        }
        return entry.startsOn.startInstant
    }
}
