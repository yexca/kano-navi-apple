/// One post timeline: where it starts and whose posts it lists.
nonisolated struct PostTimelineKey: Hashable, Sendable {
    /// The month the timeline starts at, or `nil` for the newest post.
    var start: ArchiveMonthKey?
    /// The account the API's `account` parameter narrows to, or `nil` for
    /// every post.
    var account: String?

    /// The query for one page of this timeline.
    func page(_ page: Int) -> PostTimelineQuery {
        PostTimelineQuery(start: start, account: account, page: page)
    }
}
