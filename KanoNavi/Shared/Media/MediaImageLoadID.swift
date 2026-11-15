/// What a `MediaImage` load depends on: a new value starts a new load and
/// cancels the one before.
nonisolated struct MediaImageLoadID: Hashable, Sendable {
    /// `nil` before the view has a size.
    let request: MediaImageRequest?
    /// Counts Try Again.
    let attempt: Int

    /// How long a view already showing an image waits before it loads the
    /// image at a new size. A window being resized changes the size every
    /// frame; waiting means only the size it stops at is fetched and decoded.
    static let resizeSettleDelay: Duration = .milliseconds(150)

    /// How long a load waits before it starts: `resizeSettleDelay` while an
    /// image is on screen, so it is a new size of the same picture, and
    /// `nil` otherwise, so a first load, a new source or Try Again starts at
    /// once.
    static func delay(showingImage: Bool) -> Duration? {
        showingImage ? resizeSettleDelay : nil
    }
}
