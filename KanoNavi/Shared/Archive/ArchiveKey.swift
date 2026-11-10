/// A month of an archive as narrowed by a filter; `filter` is `nil` for all
/// items.
nonisolated struct ArchiveKey: Hashable, Sendable {
    var month: ArchiveMonthKey
    var filter: String?

    /// The query for one page of this month and filter.
    func page(_ page: Int) -> ArchiveQuery {
        ArchiveQuery(month: month, filter: filter, page: page)
    }
}
