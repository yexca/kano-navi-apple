import Foundation
import KanoNaviCore

/// One Japan month of an archive month index, such as `2026-11`.
nonisolated struct ArchiveMonthKey: Hashable, Comparable, Sendable {
    /// The month as the API writes it, `YYYY-MM`.
    let rawValue: String
    /// The month's first Japan date.
    let first: JapanDate

    /// Reads a `YYYY-MM` month; returns `nil` for anything else.
    init?(rawValue: String) {
        let parts = rawValue.split(separator: "-")
        guard parts.count == 2, parts[0].count == 4, parts[1].count == 2,
            let first = JapanDate(rawValue: rawValue + "-01")
        else { return nil }
        self.rawValue = rawValue
        self.first = first
    }

    init(containing date: JapanDate) {
        first = date.firstOfMonth
        rawValue = String(first.rawValue.prefix(7))
    }

    /// The month's last Japan date, the inclusive end of its archive range.
    var last: JapanDate {
        first.addingMonths(1).addingDays(-1)
    }

    /// The month and year, such as "November 2026".
    func title(locale: Locale) -> String {
        first.monthTitle(locale: locale)
    }

    static func < (lhs: ArchiveMonthKey, rhs: ArchiveMonthKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
