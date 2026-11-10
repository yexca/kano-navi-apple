import Foundation
import KanoNaviCore

/// One calendar entry of an event on a Japan date. A sale period has an entry
/// at its opening and one at its close, from the event's `view`.
struct NowEntry: Equatable, Identifiable {
    var id: String
    var eventID: String
    var title: NowContentText
    var startsAt: Date?
    var timePrecision: String
    var saleMark: SaleMark?
    var state: EventState
    var typeCode: String?
    var activityCode: String?
    var isMembers: Bool

    /// Whether the time is an estimate the board marks with "about".
    var isApproximate: Bool { timePrecision == "approximate" }
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
                    id: event.id + "#" + String(index),
                    eventID: event.id,
                    title: NowContentText(
                        event.title, sourceLanguage: event.sourceLanguage, translations: event.translations),
                    startsAt: calendarEntry.startsAt,
                    timePrecision: calendarEntry.timePrecision,
                    saleMark: calendarEntry.saleMark,
                    state: view.state,
                    typeCode: view.typeCode,
                    activityCode: view.activityCode,
                    isMembers: (view.typeCode ?? event.eventType) == "member"
                )
                result.append((result.count, entry))
            }
        }
        return
            result
            .sorted { lhs, rhs in
                switch (lhs.entry.startsAt, rhs.entry.startsAt) {
                case (nil, nil): lhs.order < rhs.order
                case (nil, _): true
                case (_, nil): false
                case (let left?, let right?): left == right ? lhs.order < rhs.order : left < right
                }
            }
            .map(\.entry)
    }
}
