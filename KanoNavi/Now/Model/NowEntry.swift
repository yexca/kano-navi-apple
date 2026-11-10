import Foundation
import KanoNaviComponents
import KanoNaviCore

/// One calendar entry of an event. A sale period has an entry at its opening
/// and one at its close, from the event's `view`.
struct NowEntry: Equatable, Identifiable {
    var id: String
    /// The event the entry belongs to, for its title, state and marks.
    var event: ScheduleEvent
    /// The calendar entry that places the event on a day.
    var calendarEntry: CalendarEntryView

    var eventID: String { event.id }
    /// The state the server decided for the event.
    var state: EventState { event.displayState }
    var date: JapanDate { calendarEntry.startsOn }

    /// The entry's clock time; `nil` for a date-only entry or one whose time
    /// is not known.
    var startsAt: Date? {
        guard let startsAt = calendarEntry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: calendarEntry.timePrecision)
        else { return nil }
        return startsAt
    }

    /// When the entry is over: the event's end for the event's own entry,
    /// else the entry's start, such as a sale's opening. `nil` without a
    /// clock time.
    var endedAt: Date? {
        guard let startsAt else { return nil }
        return calendarEntry.saleMark == nil ? (event.endsAt ?? startsAt) : startsAt
    }
}

extension NowEntry {
    /// Every calendar entry of the events in schedule order: by Japan date,
    /// date-only entries first within a day, then by start, ties in the
    /// API's order.
    static func entries(in events: [ScheduleEvent]) -> [NowEntry] {
        var result: [(order: Int, entry: NowEntry)] = []
        for event in events {
            guard let view = event.view else { continue }
            for (index, calendarEntry) in view.calendarEntries.enumerated() {
                let entry = NowEntry(
                    id: event.id + "#" + String(index), event: event, calendarEntry: calendarEntry)
                result.append((result.count, entry))
            }
        }
        return
            result
            .sorted { lhs, rhs in
                if lhs.entry.date != rhs.entry.date {
                    return lhs.entry.date < rhs.entry.date
                }
                switch (lhs.entry.startsAt, rhs.entry.startsAt) {
                case (nil, nil): return lhs.order < rhs.order
                case (nil, _): return true
                case (_, nil): return false
                case (let left?, let right?): return left == right ? lhs.order < rhs.order : left < right
                }
            }
            .map(\.entry)
    }
}
