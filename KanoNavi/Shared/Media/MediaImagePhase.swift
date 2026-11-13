import CoreGraphics

/// What a `MediaImage` has to draw.
nonisolated enum MediaImagePhase {
    /// Nothing yet: the placeholder.
    case loading
    /// The decoded image, possibly a smaller copy while a larger one loads.
    case loaded(CGImage)
    /// The server does not have the file, or it is not an image.
    case unavailable
    /// The file could not be fetched; trying again may work.
    case failed

    var image: CGImage? {
        if case .loaded(let image) = self { image } else { nil }
    }
}
