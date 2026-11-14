import Foundation
import KanoNaviCore

nonisolated extension JapanDate {
    /// The first day of this date's month.
    var firstOfMonth: JapanDate {
        JapanDate(year: year, month: month, day: 1)
    }

    /// The first day of the month `months` months away from this date's month.
    func addingMonths(_ months: Int) -> JapanDate {
        let index = year * 12 + (month - 1) + months
        return JapanDate(year: index / 12, month: index % 12 + 1, day: 1)
    }

    /// The number of days in this date's month.
    var daysInMonth: Int {
        switch month {
        case 2:
            let isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return isLeap ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    /// The Monday-first column, 0 to 6, of this date's weekday.
    var mondayFirstColumn: Int {
        // Days since 1970-01-01, a Thursday (column 3), by the civil-from-days
        // algorithm, so no calendar object is made.
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        let days = era * 146_097 + dayOfEra - 719_468
        return ((days + 3) % 7 + 7) % 7
    }

    /// The Monday-first weeks of this date's month, with `nil` for the
    /// leading and trailing places that belong to the months around it.
    var monthWeekLayout: [[JapanDate?]] {
        let first = firstOfMonth
        let leading = first.mondayFirstColumn
        let count = daysInMonth
        let places: [JapanDate?] =
            Array(repeating: nil, count: leading)
            + (1...count).map { JapanDate(year: year, month: month, day: $0) }
        let padded = places + Array(repeating: nil, count: (7 - places.count % 7) % 7)
        return stride(from: 0, to: padded.count, by: 7).map { Array(padded[$0..<$0 + 7]) }
    }

    /// Whether this date falls on a Saturday or a Sunday.
    var isWeekend: Bool {
        mondayFirstColumn >= 5
    }

    /// Whether this date falls in the same month as `other`.
    func isInSameMonth(as other: JapanDate) -> Bool {
        year == other.year && month == other.month
    }

    /// This date's instant at midnight in Japan, for formatting.
    var startInstant: Date {
        JapanTime.startOfDay(self) ?? Date(timeIntervalSince1970: 0)
    }

    /// The month and year, such as "November 2026", or "Nov 2026" when
    /// `abbreviated`, in the given locale.
    func monthTitle(locale: Locale, abbreviated: Bool = false) -> String {
        startInstant.formatted(Self.style(locale: locale).month(abbreviated ? .abbreviated : .wide).year())
    }

    /// The month alone, abbreviated, such as "Nov" or "11月".
    func shortMonthTitle(locale: Locale) -> String {
        startInstant.formatted(Self.style(locale: locale).month(.abbreviated))
    }

    /// The full date with its weekday, such as "Tuesday, November 10".
    func dayTitle(locale: Locale) -> String {
        startInstant.formatted(Self.style(locale: locale).weekday(.wide).month(.wide).day())
    }

    /// The full date with its weekday and year, for VoiceOver.
    func accessibilityTitle(locale: Locale) -> String {
        startInstant.formatted(Self.style(locale: locale).weekday(.wide).month(.wide).day().year())
    }

    private static func style(locale: Locale) -> Date.FormatStyle {
        Date.FormatStyle(
            date: .omitted, time: .omitted, locale: locale, calendar: Calendar(identifier: .gregorian),
            timeZone: JapanDate.timeZone)
    }
}
