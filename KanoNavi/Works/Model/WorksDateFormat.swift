import Foundation
import KanoNaviCore

/// Formats the Works collection's Japan dates with their year, such as
/// `Mar 4, 2020`, for any interface locale.
nonisolated enum WorksDateFormat {
    /// A Japan date with its year. The collection's dates are calendar dates
    /// in Japan, so the device's time zone and calendar never move them.
    static func date(_ date: JapanDate, locale: Locale) -> String {
        guard let instant = JapanTime.startOfDay(date) else { return date.rawValue }
        return instant.formatted(
            Date.FormatStyle(
                date: .abbreviated, time: .omitted, locale: locale,
                calendar: Calendar(identifier: .gregorian),
                timeZone: JapanDate.timeZone))
    }

    /// A length in words for VoiceOver, such as `4 minutes, 49 seconds`,
    /// or `nil` when it is unknown.
    static func spokenLength(seconds: Int?, locale: Locale) -> String? {
        guard let seconds, seconds > 0 else { return nil }
        return Duration.seconds(seconds).formatted(
            .units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(locale))
    }

    /// A length as the platforms show it, such as `4:49` or `2:01:05`, or
    /// `nil` when it is unknown.
    static func length(seconds: Int?) -> String? {
        guard let seconds, seconds > 0 else { return nil }
        let pattern: Duration.TimeFormatStyle.Pattern = seconds >= 3600 ? .hourMinuteSecond : .minuteSecond
        return Duration.seconds(seconds).formatted(.time(pattern: pattern))
    }
}
