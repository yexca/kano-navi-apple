import Foundation
import KanoNaviComponents
import KanoNaviCore

/// What a List mode row shows for one entry of the selected day, as in
/// Calendar: its title, a quiet line with its notable state, type and
/// activity, and
/// its start and end in Japan time on the trailing side, or "All Day" for an
/// entry without a clock time.
nonisolated struct ScheduleDayRowModel: Equatable {
    /// The trailing time column.
    enum Time: Equatable {
        /// No clock time: a date-only entry, or one whose time is unknown.
        case allDay
        /// The start's clock time, and the end's when the event has one: a
        /// clock time on the same Japan day, else the end's short date.
        case clock(start: String, end: String?)
    }

    /// A state worth naming in the row; an upcoming or done entry has none.
    enum Status: Equatable {
        case live
        case sale(SaleMark)
        case state(EventState)
    }

    let title: String
    let tag: ScheduleTag
    let time: Time
    let status: Status?
    /// The type's display code, named in the row's quiet line. The service
    /// leaves it out when the activity label stands in for a plain stream.
    let typeCode: String?
    /// The activity's display code, named after the type.
    let activityCode: String?
    let isFaded: Bool
    let isCancelled: Bool

    init(_ item: ScheduleDayEntry, contentLanguage: ContentLanguage, locale: Locale) {
        let event = item.event
        let entry = item.entry
        title = event.resolvedTitle(preference: contentLanguage, interfaceLocale: locale).text
        tag = ScheduleTag(event: event)
        typeCode = event.view?.typeCode
        activityCode = event.view?.activityCode
        isFaded = event.isFadedInSchedule
        isCancelled = event.isCancelled
        time = Self.time(of: item, locale: locale)
        if let mark = entry.saleMark {
            status = .sale(mark)
        } else {
            switch event.displayState {
            case .live: status = .live
            case .open, .pending, .cancelled, .cancellationReview: status = .state(event.displayState)
            default: status = nil
            }
        }
    }

    private static func time(of item: ScheduleDayEntry, locale: Locale) -> Time {
        let entry = item.entry
        guard let startsAt = entry.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: entry.timePrecision)
        else { return .allDay }
        let start = JSTTimeFormat.clockTime(startsAt, locale: locale)
        // A sale's entry is one moment: its opening or its close.
        guard entry.saleMark == nil, let endsAt = item.event.endsAt, endsAt > startsAt else {
            return .clock(start: start, end: nil)
        }
        if JapanDate.date(from: endsAt) == entry.startsOn {
            return .clock(start: start, end: JSTTimeFormat.clockTime(endsAt, locale: locale))
        }
        let date = endsAt.formatted(
            Date.FormatStyle(
                date: .omitted, time: .omitted, locale: locale, calendar: Calendar(identifier: .gregorian),
                timeZone: JapanDate.timeZone
            ).month(.defaultDigits).day())
        return .clock(start: start, end: date)
    }

    /// Whether the quiet line has anything to name.
    var hasDetail: Bool {
        status != nil || typeCode != nil || activityCode != nil
    }

    /// Whether the time column shows a clock time, so the list names the
    /// time zone.
    var isTimed: Bool {
        if case .clock = time { true } else { false }
    }
}
