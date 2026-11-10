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
        var style = Date.FormatStyle(locale: locale, calendar: Calendar(identifier: .gregorian))
            .weekday(.abbreviated)
        style.timeZone = JapanDate.timeZone
        return (JapanTime.startOfDay(date) ?? .now).formatted(style)
    }
}
