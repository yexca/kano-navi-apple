/// One page of a post timeline.
nonisolated struct PostTimelineQuery: Hashable, Sendable {
    /// The month the timeline starts at, or `nil` for the newest post.
    var start: ArchiveMonthKey?
    var account: String?
    var page: Int

    /// The timeline this page belongs to.
    var key: PostTimelineKey {
        PostTimelineKey(start: start, account: account)
    }
}
