import Foundation
import KanoNaviCore

/// Japan-time formatting for the Now tab. Event times are always shown in
/// Asia/Tokyo and labelled JST.
enum NowTimeFormat {
    /// A clock time in Japan, such as `21:00`.
    static func time(_ date: Date, locale: Locale) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        style.timeZone = JapanDate.timeZone
        return date.formatted(style)
    }

    /// A date and time in Japan without the year, such as `Nov 10, 21:00`.
    static func dateTime(_ date: Date, locale: Locale) -> String {
        var style = Date.FormatStyle(locale: locale).month(.abbreviated).day().hour().minute()
        style.timeZone = JapanDate.timeZone
        return date.formatted(style)
    }

    /// A Japan date with its weekday, such as `Tue, Nov 10`.
    static func day(_ date: JapanDate, locale: Locale) -> String {
        guard let instant = JapanTime.startOfDay(date) else { return date.rawValue }
        var style = Date.FormatStyle(locale: locale).weekday(.abbreviated).month(.abbreviated).day()
        style.timeZone = JapanDate.timeZone
        return instant.formatted(style)
    }

    /// Whether a countdown to `date` reads better as a running timer than as
    /// a relative phrase such as "in 3 days".
    static func usesTimer(until date: Date, now: Date) -> Bool {
        date.timeIntervalSince(now) < 24 * 60 * 60
    }
}
