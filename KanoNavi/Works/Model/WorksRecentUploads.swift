import KanoNaviCore

/// The stored videos dated after the collection, which the Uploads screen
/// shows above the list: newest first, a few at a time.
nonisolated struct WorksRecentUploads: Equatable, Sendable {
    /// How many videos show before the reader asks for the rest.
    static let collapsedLimit = 3

    /// The videos the service sent, newest first (at most 48).
    let videos: [WorksRecentUpload]
    /// How many videos there are in all.
    let total: Int
    /// The date the videos come after.
    let since: JapanDate

    /// `nil` when the stored data is missing or lists no newer video.
    init?(_ stored: WorksUploadsResponse?) {
        guard let stored, stored.recent.isEmpty == false else { return nil }
        videos = stored.recent
        total = max(stored.recentTotal, stored.recent.count)
        since = stored.updatedAt
    }

    /// The videos to list.
    func shown(expanded: Bool) -> [WorksRecentUpload] {
        expanded ? videos : Array(videos.prefix(Self.collapsedLimit))
    }

    /// How many more videos expanding the list shows.
    var collapsedCount: Int {
        max(videos.count - Self.collapsedLimit, 0)
    }
}
