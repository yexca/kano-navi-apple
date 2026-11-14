/// One page of the video timeline from where it starts.
nonisolated struct VideoTimelineQuery: Hashable, Sendable {
    /// The month the timeline starts at, or `nil` for the newest video.
    var start: ArchiveMonthKey?
    var page: Int
}
