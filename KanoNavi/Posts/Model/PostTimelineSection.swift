import KanoNaviCore

/// One Japan month of the post timeline and its posts, newest first.
struct PostTimelineSection: Equatable, Identifiable {
    var month: ArchiveMonthKey
    var cards: [PostCard]

    var id: String { month.rawValue }

    /// The cards grouped by the Japan month they were published in, in the
    /// cards' order; a month met again later joins its first section, so
    /// each month is listed once.
    static func grouping(_ cards: [PostCard]) -> [PostTimelineSection] {
        var sections: [PostTimelineSection] = []
        var positions: [ArchiveMonthKey: Int] = [:]
        for card in cards {
            let month = ArchiveMonthKey(containing: JapanDate.date(from: card.publishedAt))
            if let position = positions[month] {
                sections[position].cards.append(card)
            } else {
                positions[month] = sections.count
                sections.append(PostTimelineSection(month: month, cards: [card]))
            }
        }
        return sections
    }

    /// The `id` of the first of `sections`, in their order, that lists a post
    /// in `visible`, or `nil` when none does.
    static func topID(of sections: [PostTimelineSection], visible: [TimelineSlot]) -> String? {
        TimelineSlot.topSectionID(of: sections.map(\.id), visible: visible)
    }
}
