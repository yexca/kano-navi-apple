/// One milestone's place on the timeline, its identity in the scroll view, so
/// the milestones on screen tell which year is at the top.
nonisolated struct JourneyTimelineSlot: Hashable {
    /// The year the milestone is listed under.
    var year: Int
    /// The milestone's `id`.
    var milestoneID: String
}

nonisolated extension JourneyTimeline {
    /// The year of the first of `groups`, in their order, that lists a
    /// milestone in `visible`, or `nil` when none does.
    static func topYear(of groups: [JourneyYearGroup], visible: [JourneyTimelineSlot]) -> Int? {
        let shown = Set(visible.map(\.year))
        return groups.first { shown.contains($0.year) }?.year
    }
}
