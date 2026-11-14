import KanoNaviCore

/// One Japan month of the video timeline and its videos, newest first.
struct VideoTimelineSection: Equatable, Identifiable {
    /// The month of the videos' times, or `nil` for videos without one
    /// before any dated video.
    var month: ArchiveMonthKey?
    var cards: [VideoCard]

    var id: String { month?.rawValue ?? "" }

    /// The cards grouped by the Japan month of their times, in the cards'
    /// order. A card without a time stays with the card before it; a month
    /// met again later joins its first section, so each month is listed
    /// once.
    static func grouping(_ cards: [VideoCard]) -> [VideoTimelineSection] {
        var sections: [VideoTimelineSection] = []
        var positions: [ArchiveMonthKey?: Int] = [:]
        var month: ArchiveMonthKey?
        for card in cards {
            if let time = card.time {
                month = ArchiveMonthKey(containing: JapanDate.date(from: time))
            }
            if let position = positions[month] {
                sections[position].cards.append(card)
            } else {
                positions[month] = sections.count
                sections.append(VideoTimelineSection(month: month, cards: [card]))
            }
        }
        return sections
    }
}
