/// One video's place in the timeline, its identity in the scroll view, so the
/// videos on screen tell which section is at the top.
struct VideoTimelineSlot: Hashable {
    /// The `id` of the section the video is listed in.
    var sectionID: String
    /// The video's card `id`.
    var cardID: String
}

extension VideoTimelineSection {
    /// The `id` of the first of `sections`, in their order, that lists a video
    /// in `visible`, or `nil` when none does.
    static func topID(of sections: [VideoTimelineSection], visible: [VideoTimelineSlot]) -> String? {
        let shown = Set(visible.map(\.sectionID))
        return sections.first { shown.contains($0.id) }?.id
    }
}
