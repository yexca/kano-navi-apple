extension VideoTimelineSection {
    /// The `id` of the first of `sections`, in their order, that lists a video
    /// in `visible`, or `nil` when none does.
    static func topID(of sections: [VideoTimelineSection], visible: [TimelineSlot]) -> String? {
        TimelineSlot.topSectionID(of: sections.map(\.id), visible: visible)
    }
}
