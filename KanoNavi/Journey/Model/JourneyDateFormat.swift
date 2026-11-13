import Foundation
import KanoNaviCore

/// Words Journey dates as Japan dates, keeping a milestone's stored
/// precision: a year or a month is never shown as a day.
///
/// | Stored         | `short` (in its year's section) | `full`                         |
/// | -------------- | ------------------------------- | ------------------------------ |
/// | `2016`         | `2016`                          | `2016`                         |
/// | `2016-09`      | `Sep`                           | `September 2016`               |
/// | `2016-09-07`   | `Sep 7`                         | `September 7, 2016`            |
/// | with `dateEnd` | `Jun 25 – Sep 30`               | `Jun 25 – Sep 30, 2024`        |
nonisolated enum JourneyDateFormat {
    /// The date as a row in its year's section shows it. A range that ends
    /// in another year names both years.
    static func short(_ date: JourneyDate, end: JapanDate? = nil, locale: Locale) -> String {
        let style = style(locale: locale)
        if let range = dayRange(date, end: end) {
            let interval = intervalStyle(date: nil, locale: locale)
            let sameYear = date.year == end?.year
            return range.formatted(
                sameYear
                    ? interval.month(.abbreviated).day()
                    : interval.year().month(.abbreviated).day())
        }
        let start =
            switch date.precision {
            case .day: format(date, style.month(.abbreviated).day())
            case .month: format(date, style.month(.abbreviated))
            case .year: format(date, style.year())
            }
        return joined(start, from: date, end: end, locale: locale)
    }

    /// The whole date, with its year, for the detail screen and VoiceOver.
    static func full(_ date: JourneyDate, end: JapanDate? = nil, locale: Locale) -> String {
        if let range = dayRange(date, end: end) {
            return range.formatted(intervalStyle(date: .abbreviated, locale: locale))
        }
        let style = style(locale: locale)
        let start =
            switch date.precision {
            case .day: format(date, Date.FormatStyle(date: .long, time: .omitted).merging(style))
            case .month: format(date, style.year().month(.wide))
            case .year: format(date, style.year())
            }
        return joined(start, from: date, end: end, locale: locale)
    }

    /// A media item's Japan date, such as `Sep 7, 2016`.
    static func day(_ date: JapanDate, locale: Locale) -> String {
        format(
            JourneyDate(date),
            Date.FormatStyle(date: .abbreviated, time: .omitted).merging(style(locale: locale)))
    }

    /// The span from a day to a later `end`, or `nil` when there is no such
    /// span (no end, an end on or before the start, or a start that is not a
    /// day).
    private static func dayRange(_ date: JourneyDate, end: JapanDate?) -> Range<Date>? {
        guard let end, let startDay = date.japanDate, startDay < end,
            let lower = JapanTime.startOfDay(startDay), let upper = JapanTime.startOfDay(end)
        else { return nil }
        return lower..<upper
    }

    /// The worded start, and the end day when it comes after `date`, joined
    /// with a dash. Only a year or a month start reaches the join: a day
    /// start with a later end is an interval.
    private static func joined(_ start: String, from date: JourneyDate, end: JapanDate?, locale: Locale)
        -> String
    {
        guard let end, date.precision != .day, JourneyDate(end) > date else { return start }
        var resource = LocalizedStringResource.Journey.dateRange(start, day(end, locale: locale))
        resource.locale = locale
        return String(localized: resource)
    }

    private static func format(_ date: JourneyDate, _ style: Date.FormatStyle) -> String {
        guard
            let instant = JapanTime.calendar.date(
                from: DateComponents(year: date.year, month: date.month ?? 1, day: date.day ?? 1))
        else { return date.rawValue }
        return instant.formatted(style)
    }

    private static func style(locale: Locale) -> Date.FormatStyle {
        Date.FormatStyle(
            date: .omitted, time: .omitted, locale: locale, calendar: Calendar(identifier: .gregorian),
            timeZone: JapanDate.timeZone)
    }

    private static func intervalStyle(date: Date.IntervalFormatStyle.DateStyle?, locale: Locale)
        -> Date.IntervalFormatStyle
    {
        Date.IntervalFormatStyle(
            date: date, time: nil, locale: locale, calendar: Calendar(identifier: .gregorian),
            timeZone: JapanDate.timeZone)
    }
}

extension Date.FormatStyle {
    /// This style with the locale, calendar and time zone of `other`.
    nonisolated fileprivate func merging(_ other: Date.FormatStyle) -> Date.FormatStyle {
        var style = self
        style.locale = other.locale
        style.calendar = other.calendar
        style.timeZone = other.timeZone
        return style
    }
}
