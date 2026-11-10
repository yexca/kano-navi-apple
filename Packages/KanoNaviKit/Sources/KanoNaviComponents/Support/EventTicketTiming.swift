import Foundation
import KanoNaviCore

/// What an ``EventTicketRow`` says about when an entry happens, relative to
/// an instant: live now, a clock time ("in 3 hours", "2 hours ago") or a
/// Japan day ("today", "tomorrow", "in 4 days").
///
/// A clock time is used for entries on today's Japan date and for entries
/// less than ``nearWindow`` away, so a stream after midnight reads "in 3
/// hours"; later entries, and entries without a clock time, read as days
/// from today's Japan date, matching their day header.
public nonisolated enum EventTicketTiming: Equatable, Sendable {
    /// The entry is live now; `endsAt` is its end time when the event has
    /// one.
    case live(endsAt: Date?)
    /// The entry's start, to be read relative to now.
    case relativeTime(Date)
    /// Japan days from today to the entry's date: 0 is today, 1 tomorrow.
    case relativeDay(Int)

    /// Entries closer than this read as a clock time even on another day.
    public static let nearWindow: TimeInterval = 12 * 60 * 60

    /// The timing of one calendar entry at `now`. Only the event's own
    /// entry is live; a sale's opening or close never is.
    public init(event: ScheduleEvent, entry: CalendarEntryView, now: Date) {
        if event.displayState == .live, entry.saleMark == nil {
            self = .live(endsAt: event.endsAt)
            return
        }
        let today = JapanDate.today(at: now)
        if let startsAt = entry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: entry.timePrecision),
            entry.startsOn == today || abs(startsAt.timeIntervalSince(now)) < Self.nearWindow
        {
            self = .relativeTime(startsAt)
        } else {
            self = .relativeDay(Self.dayOffset(from: today, to: entry.startsOn))
        }
    }

    /// The relative phrase in the interface language, such as "in 3 hours"
    /// or "tomorrow", using the system's relative date formatting. `nil`
    /// while live, which the row says in its own words.
    public func relativeText(now: Date, locale: Locale) -> String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = Self.japanCalendar
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        switch self {
        case .live:
            return nil
        case .relativeTime(let date):
            return formatter.localizedString(for: date, relativeTo: now)
        case .relativeDay(let days):
            return formatter.localizedString(from: DateComponents(day: days))
        }
    }

    /// Whole Japan days from one date to another.
    public static func dayOffset(from start: JapanDate, to end: JapanDate) -> Int {
        guard let from = JapanTime.startOfDay(start), let to = JapanTime.startOfDay(end) else { return 0 }
        return japanCalendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    private static var japanCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = JapanDate.timeZone
        return calendar
    }
}
