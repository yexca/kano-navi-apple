/// One page of an archive month, optionally narrowed by a filter code such as
/// a video category or a post account.
nonisolated struct ArchiveQuery: Hashable, Sendable {
    var month: ArchiveMonthKey
    var filter: String?
    var page: Int

    /// The month and filter this page belongs to.
    var key: ArchiveKey {
        ArchiveKey(month: month, filter: filter)
    }
}
