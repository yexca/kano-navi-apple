import Foundation
import KanoNaviComponents
import KanoNaviCore

/// One calendar entry as the widgets show it: an event's start, or a sale's
/// opening or closing, with its title already resolved for the content
/// language.
nonisolated struct WidgetItem: Equatable, Identifiable, Sendable {
    /// Unique within a schedule: the event ID plus the entry's position.
    var id: String
    var eventID: String
    var title: String
    /// The Japan date the entry is listed on.
    var day: JapanDate
    /// The entry's instant; `nil` when the server only knows the date.
    var startsAt: Date?
    /// How precise `startsAt` is: `exact`, `approximate`, `date` or
    /// `unknown`. Only entries with a clock time show one.
    var timePrecision = "exact"
    /// When the event ends. Sale entries have none; their closing is an
    /// entry of its own.
    var endsAt: Date?
    var saleMark: SaleMark?
    var state: EventState
    var typeCode: String?

    /// The entry's color family, as in the app's calendar.
    var tag: ScheduleTag { ScheduleTag(typeCode: typeCode) }
    var isMembers: Bool { typeCode == "member" }
    var isCancelled: Bool { state == .cancelled }
    var isCancellationSuspected: Bool { state == .cancellationReview }

    /// The event this entry belongs to, opened by tapping it.
    var url: URL { WidgetDeepLink.event(eventID) }

    /// Whether the server marks the event live and it has not reached its end.
    func isLive(at now: Date) -> Bool {
        guard saleMark == nil, state == .live else { return false }
        return endsAt.map { $0 > now } ?? true
    }

    /// Whether the entry's time has passed. A date-only entry stays current
    /// for its whole Japan day.
    func isPast(at now: Date) -> Bool {
        if let startsAt {
            startsAt <= now
        } else {
            day < JapanDate.date(from: now)
        }
    }

    /// The instants at which this entry changes how the widgets show it.
    var transitionDates: [Date] {
        if let startsAt {
            return [startsAt, endsAt].compactMap(\.self)
        }
        return [JapanTime.startOfDay(day), JapanTime.startOfDay(day.addingDays(1)), endsAt]
            .compactMap(\.self)
    }
}
