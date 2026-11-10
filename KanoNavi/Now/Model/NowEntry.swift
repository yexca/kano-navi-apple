import Foundation
import KanoNaviCore

/// One calendar entry of an event on a Japan date. A sale period has an entry
/// at its opening and one at its close, from the event's `view`.
struct NowEntry: Equatable, Identifiable {
    var id: String
    /// The event the entry belongs to, for its chips and platforms.
    var event: ScheduleEvent
    /// The calendar entry that places the event on the day.
    var calendarEntry: CalendarEntryView

    var eventID: String { event.id }
    var title: NowContentText {
        NowContentText(event.title, sourceLanguage: event.sourceLanguage, translations: event.translations)
    }
    var saleMark: SaleMark? { calendarEntry.saleMark }
    /// The state the server decided for the event.
    var state: EventState { event.view?.state ?? .unknown("") }

    /// Whether the time is an estimate the board marks with "about".
    var isApproximate: Bool { calendarEntry.timePrecision == "approximate" }
}

extension NowEntry {
    /// The entries of the snapshot's events on one Japan date, in time order;
    /// date-only entries come first, and ties keep the API's order.
    static func entries(on date: JapanDate, in events: [ScheduleEvent]) -> [NowEntry] {
        var result: [(order: Int, entry: NowEntry)] = []
        for event in events {
            guard let view = event.view else { continue }
            for (index, calendarEntry) in view.calendarEntries.enumerated()
            where calendarEntry.startsOn == date {
                let entry = NowEntry(
                    id: event.id + "#" + String(index), event: event, calendarEntry: calendarEntry)
                result.append((result.count, entry))
            }
        }
        return
            result
            .sorted { lhs, rhs in
                switch (lhs.entry.calendarEntry.startsAt, rhs.entry.calendarEntry.startsAt) {
                case (nil, nil): lhs.order < rhs.order
                case (nil, _): true
                case (_, nil): false
                case (let left?, let right?): left == right ? lhs.order < rhs.order : left < right
                }
            }
            .map(\.entry)
    }
}
