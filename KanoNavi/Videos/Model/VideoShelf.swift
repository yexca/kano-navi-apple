import KanoNaviCore

/// The dashboard's video shelf: the projection's IDs joined to the snapshot's
/// videos, in the projection's order. An ID without a video is left out.
struct VideoShelf: Equatable {
    /// The shelf's lead: the operator's featured video, or the latest work.
    var lead: VideoCard?
    var leadIsFeatured: Bool
    var reservations: [VideoCard]
    var works: [VideoCard]
    var archives: [VideoCard]
    var shorts: [VideoCard]

    init(dashboard: Dashboard) {
        let shelf = dashboard.projection?.shelf
        var videos: [String: Video] = [:]
        for video in dashboard.videos where videos[video.id] == nil {
            videos[video.id] = video
        }
        func cards(_ ids: [String]?) -> [VideoCard] {
            (ids ?? []).compactMap { videos[$0].map(VideoCard.init) }
        }
        lead = shelf?.leadID.flatMap { videos[$0] }.map(VideoCard.init)
        leadIsFeatured = lead != nil && shelf?.leadIsFeatured == true
        reservations = cards(shelf?.reservations)
        works = cards(shelf?.works)
        archives = cards(shelf?.archives)
        shorts = cards(shelf?.shorts)
    }

    /// Whether the shelf has no video at all.
    var isEmpty: Bool {
        lead == nil && reservations.isEmpty && works.isEmpty && archives.isEmpty && shorts.isEmpty
    }
}
