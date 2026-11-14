/// What the video shelf shows: one kind and one platform, each `nil` for
/// all. Applied on the device to the shelf the projection gives.
struct VideoShelfFilter: Equatable {
    var kind: VideoShelfKind?
    var platform: VideoShelfPlatform?
}

extension VideoShelf {
    /// Every video on the shelf once: the lead, then each group in order.
    var cards: [VideoCard] {
        (lead.map { [$0] } ?? []) + reservations + works + archives + shorts
    }

    /// The kinds on the shelf, in the filter's order.
    var kinds: [VideoShelfKind] {
        let present = Set(cards.map(\.kind))
        return VideoShelfKind.allCases.filter(present.contains)
    }

    /// The platforms the shelf's videos are on, in the menu's order.
    var platforms: [VideoShelfPlatform] {
        VideoShelfPlatform.allCases.filter { platform in cards.contains { $0.isOn(platform) } }
    }

    /// The filter as the shelf can apply it: a kind or a platform that the
    /// shelf does not offer is all of them. A choice is offered only when
    /// there are two to choose between, as the web board does.
    func resolved(_ filter: VideoShelfFilter) -> VideoShelfFilter {
        let kinds = kinds
        let platforms = platforms
        return VideoShelfFilter(
            kind: kinds.count > 1 ? filter.kind.flatMap { kinds.contains($0) ? $0 : nil } : nil,
            platform: platforms.count > 1
                ? filter.platform.flatMap { platforms.contains($0) ? $0 : nil } : nil)
    }

    /// The kind filter's choices: all, then each kind on the shelf, counting
    /// the videos on the chosen platform. Empty with fewer than two kinds.
    func kindOptions(on platform: VideoShelfPlatform?) -> [ArchiveFilterOption] {
        let kinds = kinds
        guard kinds.count > 1 else { return [] }
        let onPlatform = cards.filter { card in platform.map(card.isOn) ?? true }
        let all = ArchiveFilterOption(code: nil, label: .localized(.Archive.all), count: onPlatform.count)
        return [all]
            + kinds.map { kind in
                ArchiveFilterOption(
                    code: kind.rawValue, label: .localized(kind.label),
                    count: onPlatform.count { $0.kind == kind })
            }
    }

    /// The shelf narrowed by a filter. The lead stays the lead when it
    /// matches and is left out otherwise; each group keeps its matching
    /// videos in order. With a platform chosen, each card's link to that
    /// platform comes first.
    func narrowed(by filter: VideoShelfFilter) -> VideoShelf {
        func keep(_ card: VideoCard) -> VideoCard? {
            if let kind = filter.kind, card.kind != kind { return nil }
            guard let platform = filter.platform else { return card }
            return card.isOn(platform) ? card.leading(with: platform) : nil
        }
        var shelf = self
        shelf.lead = lead.flatMap(keep)
        shelf.leadIsFeatured = shelf.lead != nil && leadIsFeatured
        shelf.reservations = reservations.compactMap(keep)
        shelf.works = works.compactMap(keep)
        shelf.archives = archives.compactMap(keep)
        shelf.shorts = shorts.compactMap(keep)
        return shelf
    }
}
