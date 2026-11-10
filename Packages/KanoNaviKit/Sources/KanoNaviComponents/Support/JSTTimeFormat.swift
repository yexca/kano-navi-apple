import Foundation
import KanoNaviCore

/// Formats event times in Japan time, labelled JST, for any interface locale.
///
/// Times are always shown in Asia/Tokyo with the Gregorian calendar, whatever
/// the device's time zone or calendar. Pass the view's `\.locale` so the
/// formatting follows the interface language.
public nonisolated enum JSTTimeFormat {
    /// Whether an entry has a clock time to show. Date-only entries, and
    /// entries whose time is not known, show only their date.
    public static func showsTime(startsAt: Date?, timePrecision: String) -> Bool {
        startsAt != nil && timePrecision != "date" && timePrecision != "unknown"
    }

    /// The clock time alone, such as `21:00`, in Japan time.
    public static func clockTime(_ instant: Date, locale: Locale) -> String {
        instant.formatted(style(date: .omitted, time: .shortened, locale: locale))
    }

    /// The clock time labelled JST, such as `21:00 JST`.
    public static func time(_ instant: Date, locale: Locale) -> String {
        string(ComponentStrings.timeJST(clockTime(instant, locale: locale)), locale: locale)
    }

    /// A Japan date with its weekday, such as `Thu, Nov 12`.
    public static func day(_ date: JapanDate, locale: Locale) -> String {
        guard let instant = JapanTime.startOfDay(date) else { return date.rawValue }
        return instant.formatted(
            style(date: .omitted, time: .omitted, locale: locale).weekday(.abbreviated).month(.abbreviated)
                .day())
    }

    /// A date and clock time labelled JST, such as `Thu, Nov 12 21:00 JST`.
    public static func dateTime(_ instant: Date, locale: Locale) -> String {
        string(
            ComponentStrings.dateTimeJST(
                date: day(JapanDate.date(from: instant), locale: locale),
                time: clockTime(instant, locale: locale)),
            locale: locale)
    }

    /// The text for an entry's start: its time labelled JST, or for a
    /// date-only entry its date. Returns `nil` for a date-only entry when
    /// `includesDate` is `false`, since such an entry has no time to show.
    public static func entry(
        startsAt: Date?, startsOn: JapanDate, timePrecision: String, includesDate: Bool, locale: Locale
    ) -> String? {
        if let startsAt, showsTime(startsAt: startsAt, timePrecision: timePrecision) {
            return includesDate ? dateTime(startsAt, locale: locale) : time(startsAt, locale: locale)
        }
        return includesDate ? day(startsOn, locale: locale) : nil
    }

    private static func style(
        date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle, locale: Locale
    ) -> Date.FormatStyle {
        Date.FormatStyle(
            date: date, time: time, locale: locale, calendar: Calendar(identifier: .gregorian),
            timeZone: JapanDate.timeZone)
    }

    private static func string(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
