/// What the video timeline shows: one kind and one platform, each `nil` for
/// all. The API cannot narrow the timeline by either, so it is applied on
/// the device to the pages loaded.
struct VideoTimelineFilter: Hashable {
    var kind: VideoShelfKind?
    var platform: VideoShelfPlatform?

    /// Whether a choice other than All is made.
    var isActive: Bool {
        kind != nil || platform != nil
    }

    /// The card as the filter shows it, or `nil` when it does not match. With
    /// a platform chosen, the card's page on that platform is its first link.
    func apply(to card: VideoCard) -> VideoCard? {
        if let kind, card.kind != kind { return nil }
        guard let platform else { return card }
        return card.isOn(platform) ? card.leading(with: platform) : nil
    }
}
