import Foundation

/// A calendar date in Japan, independent of an instant at midnight.
public enum JapanTime {
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = JapanDate.timeZone
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 1
        return calendar
    }()

    public static func dateStyle(locale: Locale = .current) -> Date.FormatStyle {
        var style = Date.FormatStyle(date: .numeric, time: .omitted).locale(locale)
        style.timeZone = JapanDate.timeZone
        return style
    }

    public static func dateTimeStyle(locale: Locale = .current) -> Date.FormatStyle {
        var style = Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale)
        style.timeZone = JapanDate.timeZone
        return style
    }

    public static func startOfDay(_ date: JapanDate) -> Date? {
        calendar.date(from: DateComponents(year: date.year, month: date.month, day: date.day))
    }
}
