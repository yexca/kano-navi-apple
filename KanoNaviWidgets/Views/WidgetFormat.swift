import Foundation
import KanoNaviCore

/// Japan-time text the widgets need beyond `JSTTimeFormat`.
nonisolated enum WidgetFormat {
    /// A catalog string resolved for `locale`, for composing into other text.
    static func string(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    /// A Japan date's abbreviated weekday, such as "Thu".
    static func weekday(_ date: JapanDate, locale: Locale) -> String {
        format(date, style(locale).weekday(.abbreviated))
    }

    /// A Japan date's narrow weekday, such as "T".
    static func narrowWeekday(_ date: JapanDate, locale: Locale) -> String {
        format(date, style(locale).weekday(.narrow))
    }

    /// A Japan date's weekday and day of the month, such as "Thu 12".
    static func shortDay(_ date: JapanDate, locale: Locale) -> String {
        format(date, style(locale).weekday(.abbreviated).day())
    }

    /// A range of Japan dates, such as "Nov 12 – 18".
    static func dayRange(from first: JapanDate, through last: JapanDate, locale: Locale) -> String {
        guard let start = JapanTime.startOfDay(first), let end = JapanTime.startOfDay(last) else {
            return first.rawValue
        }
        let style = Date.IntervalFormatStyle(
            locale: locale, calendar: Calendar(identifier: .gregorian), timeZone: JapanDate.timeZone
        )
        .month(.abbreviated).day()
        return (start..<end).formatted(style)
    }

    private static func style(_ locale: Locale) -> Date.FormatStyle {
        Date.FormatStyle(
            locale: locale, calendar: Calendar(identifier: .gregorian), timeZone: JapanDate.timeZone)
    }

    private static func format(_ date: JapanDate, _ style: Date.FormatStyle) -> String {
        (JapanTime.startOfDay(date) ?? .now).formatted(style)
    }
}
