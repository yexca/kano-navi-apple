import Foundation
import KanoNaviComponents
import KanoNaviCore

/// One calendar entry of one event on a Japan date. A sale appears twice in
/// the calendar, once where it opens and once where it closes.
nonisolated struct ScheduleDayEntry: Identifiable, Equatable, Sendable {
    let event: ScheduleEvent
    let entry: CalendarEntryView
    let id: String

    /// The entries of `events` on each day of `month`, built once when the
    /// month loads: each day's entries in server order, then by start
    /// (date-only entries first, then by time). Entries on days of other
    /// months are left out.
    static func index(of events: [ScheduleEvent], in month: JapanDate) -> [JapanDate: [ScheduleDayEntry]] {
        var days: [JapanDate: [ScheduleDayEntry]] = [:]
        for event in events {
            for (index, entry) in event.displayCalendarEntries.enumerated()
            where entry.startsOn.isInSameMonth(as: month) {
                days[entry.startsOn, default: []].append(
                    ScheduleDayEntry(event: event, entry: entry, id: "\(event.id)#\(index)"))
            }
        }
        return days.mapValues(sorted)
    }

    /// Sorts one day's entries by start, keeping server order for ties.
    private static func sorted(_ entries: [ScheduleDayEntry]) -> [ScheduleDayEntry] {
        entries.map { ($0, $0.sortTime) }
            .enumerated()
            .sorted { lhs, rhs in
                let left = lhs.element.1
                let right = rhs.element.1
                return left == right ? lhs.offset < rhs.offset : left < right
            }
            .map(\.element.0)
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
