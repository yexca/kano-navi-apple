/// One item's place in a timeline grouped into sections, its identity in the
/// scroll view, so the items on screen tell which section is at the top.
nonisolated struct TimelineSlot: Hashable, Sendable {
    /// The `id` of the section the item is listed in.
    var sectionID: String
    /// The item's `id`.
    var itemID: String

    /// The first of `sectionIDs`, in their order, that lists an item in
    /// `visible`, or `nil` when none does.
    static func topSectionID(of sectionIDs: [String], visible: [TimelineSlot]) -> String? {
        let shown = Set(visible.map(\.sectionID))
        return sectionIDs.first { shown.contains($0) }
    }
}
