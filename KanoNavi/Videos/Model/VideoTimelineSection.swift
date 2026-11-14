import KanoNaviCore

/// One part of the video timeline and its videos, newest first: the videos on
/// air now, or one Japan month.
struct VideoTimelineSection: Equatable, Identifiable {
    /// The month of the videos' times, or `nil` for videos without one
    /// before any dated video, and for the videos on air.
    var month: ArchiveMonthKey?
    /// Whether this is the section of the videos on air, which leads the
    /// timeline.
    var isOnAir = false
    var cards: [VideoCard]

    var id: String { isOnAir ? "on-air" : month?.rawValue ?? "" }

    /// The cards grouped by the Japan month of their times, in the cards'
    /// order. A card without a time stays with the card before it; a month
    /// met again later joins its first section, so each month is listed
    /// once.
    ///
    /// With `liftsOnAir`, videos that are live or past their start come first
    /// in a section of their own, ahead of the reservations dated after them.
    static func grouping(_ cards: [VideoCard], liftsOnAir: Bool = false) -> [VideoTimelineSection] {
        var sections: [VideoTimelineSection] = []
        var rest = cards
        if liftsOnAir {
            let onAir = cards.filter(\.isOnAir)
            if onAir.isEmpty == false {
                sections.append(VideoTimelineSection(isOnAir: true, cards: onAir))
                rest = cards.filter { $0.isOnAir == false }
            }
        }
        var positions: [ArchiveMonthKey?: Int] = [:]
        var month: ArchiveMonthKey?
        for card in rest {
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

extension VideoCard {
    /// Whether the video is on air: confirmed live, or past its start
    /// without a confirmed broadcast.
    var isOnAir: Bool {
        status == .live || status == .started
    }
}
