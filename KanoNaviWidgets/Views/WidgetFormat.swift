import Foundation
import KanoNaviCore

/// Japan-time formatting shared by the widget views.
nonisolated enum WidgetFormat {
    /// A time of day in Japan, such as "21:00" or "9:00 PM".
    static func time(_ date: Date, locale: Locale) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        style.timeZone = JapanDate.timeZone
        return date.formatted(style)
    }

    /// A time of day labelled as Japan time, such as "21:00 JST".
    static func timeJST(_ date: Date, locale: Locale) -> String {
        string(.widgetTimeJST(time(date, locale: locale)), locale: locale)
    }

    /// A catalog string resolved for `locale`, for composing into other text.
    static func string(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    /// A Japan date with its weekday, such as "Thu, Nov 12".
    static func day(_ date: JapanDate, locale: Locale) -> String {
        var style = Date.FormatStyle(locale: locale).weekday(.abbreviated).month(.abbreviated).day()
        style.timeZone = JapanDate.timeZone
        return (JapanTime.startOfDay(date) ?? .now).formatted(style)
    }

    /// A Japan date's abbreviated weekday, such as "Thu".
    static func weekday(_ date: JapanDate, locale: Locale) -> String {
        var style = Date.FormatStyle(locale: locale).weekday(.abbreviated)
        style.timeZone = JapanDate.timeZone
        return (JapanTime.startOfDay(date) ?? .now).formatted(style)
    }
}
