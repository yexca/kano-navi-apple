import Foundation
import KanoNaviCore

/// The months a month picker offers: each year from the current Japan year
/// back to the year of the oldest month in the index, newest first, with its
/// twelve months in calendar order.
nonisolated struct MonthGrid: Equatable, Sendable {
    var years: [MonthGridYear]

    /// - Parameters:
    ///   - index: The months that hold items, with their counts.
    ///   - today: Today's Japan date; months after its month are future
    ///     months.
    init(index: ArchiveMonthIndex, today: JapanDate) {
        let current = ArchiveMonthKey(containing: today)
        var counts: [ArchiveMonthKey: Int] = [:]
        for month in index.months {
            if let key = ArchiveMonthKey(rawValue: month.month) {
                counts[key, default: 0] += month.total
            }
        }
        guard let oldest = counts.keys.min() else {
            years = []
            return
        }
        let newestYear = current.first.year
        let oldestYear = min(oldest.first.year, newestYear)
        years = stride(from: newestYear, through: oldestYear, by: -1).map { year in
            MonthGridYear(
                year: year,
                months: (1...12).map { month in
                    let key = ArchiveMonthKey(containing: JapanDate(year: year, month: month, day: 1))
                    let count = counts[key] ?? 0
                    return MonthGridCell(month: key, count: count, isEnabled: count > 0 && key <= current)
                })
        }
    }

    /// The name of a choice, as VoiceOver reads the picker's value: the
    /// month and year, or Newest for `nil`.
    static func title(of selection: ArchiveMonthKey?, locale: Locale) -> String {
        if let selection {
            return selection.title(locale: locale)
        }
        var resource = LocalizedStringResource.Archive.newest
        resource.locale = locale
        return String(localized: resource)
    }
}
