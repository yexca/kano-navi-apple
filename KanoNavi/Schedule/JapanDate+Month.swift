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

    /// The Monday-first weeks that hold this date's month: its six-week grid
    /// without the weeks wholly in the months around it.
    var monthWeeks: [[JapanDate]] {
        let dates = firstOfMonth.monthGrid
        return stride(from: 0, to: dates.count, by: 7)
            .map { Array(dates[$0..<min($0 + 7, dates.count)]) }
            .filter { week in week.contains { $0.isInSameMonth(as: self) } }
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
