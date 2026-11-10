import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Synthetic archive months and pages of string items, for the archive model
/// tests.
enum ArchiveFixtures {
    static let november = ArchiveMonthKey(containing: JapanDate(year: 2026, month: 11, day: 1))
    static let october = ArchiveMonthKey(containing: JapanDate(year: 2026, month: 10, day: 1))
    static let fetchedAt = Date(timeIntervalSince1970: 1_794_300_000)
    static let cachedAt = Date(timeIntervalSince1970: 1_794_000_000)

    /// A month index as the API lists it, oldest first.
    static func index(isFromCache: Bool = false) -> ArchiveMonthIndex {
        ArchiveMonthIndex(
            months: [
                ArchiveMonth(month: "2026-10", total: 2, counts: ["game": 2]),
                ArchiveMonth(month: "2026-11", total: 5, counts: ["game": 1, "talk": 4]),
            ], isFromCache: isFromCache, fetchedAt: isFromCache ? cachedAt : fetchedAt)
    }

    static func page(
        _ items: [String], page: Int = 1, hasNext: Bool = false, total: Int? = nil,
        counts: [String: Int] = ["game": 1, "talk": 4], isFromCache: Bool = false, fetchedAt: Date? = nil
    ) -> ArchivePage<String> {
        ArchivePage(
            items: items, page: page, hasNext: hasNext, total: total ?? items.count, counts: counts,
            isFromCache: isFromCache, fetchedAt: fetchedAt ?? (isFromCache ? cachedAt : Self.fetchedAt))
    }

    static func query(_ month: ArchiveMonthKey = november, filter: String? = nil, page: Int = 1)
        -> ArchiveQuery
    {
        ArchiveQuery(month: month, filter: filter, page: page)
    }
}
