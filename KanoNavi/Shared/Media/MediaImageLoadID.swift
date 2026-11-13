/// What a `MediaImage` load depends on: a new value starts a new load and
/// cancels the one before.
nonisolated struct MediaImageLoadID: Hashable, Sendable {
    /// `nil` before the view has a size.
    let request: MediaImageRequest?
    /// Counts Try Again.
    let attempt: Int
}
