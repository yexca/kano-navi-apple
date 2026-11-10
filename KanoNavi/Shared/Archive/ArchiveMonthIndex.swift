import Foundation
import KanoNaviCore

/// An archive's month index: every month that holds an item, newest first,
/// and where the index came from.
nonisolated struct ArchiveMonthIndex: Equatable, Sendable {
    var months: [ArchiveMonth]
    var isFromCache: Bool
    var fetchedAt: Date

    /// The index from a month-index read, newest month first. The API lists
    /// months oldest first; months it writes in another form are left out.
    init(_ result: ReadResult<ArchiveMonthsResponse>) {
        self.init(
            months: result.value.months, isFromCache: result.isFromCache, fetchedAt: result.fetchedAt)
    }

    init(months: [ArchiveMonth], isFromCache: Bool, fetchedAt: Date) {
        self.months = months.filter { ArchiveMonthKey(rawValue: $0.month) != nil }
            .sorted { $0.month > $1.month }
        self.isFromCache = isFromCache
        self.fetchedAt = fetchedAt
    }

    /// The months as keys, newest first.
    var keys: [ArchiveMonthKey] {
        months.compactMap { ArchiveMonthKey(rawValue: $0.month) }
    }

    /// The index entry of a month.
    func month(_ key: ArchiveMonthKey) -> ArchiveMonth? {
        months.first { $0.month == key.rawValue }
    }
}
