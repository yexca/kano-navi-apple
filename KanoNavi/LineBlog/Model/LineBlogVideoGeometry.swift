import CoreGraphics

/// The shape of a video on screen.
nonisolated enum LineBlogVideoGeometry {
    /// The shape held before the stream says its own, and for a cover.
    static let defaultAspectRatio: CGFloat = 16 / 9

    /// Width over height of a video track as it is shown, with the track's
    /// rotation applied; `nil` for an empty size.
    static func aspectRatio(naturalSize: CGSize, transform: CGAffineTransform) -> CGFloat? {
        let shown = CGRect(origin: .zero, size: naturalSize).applying(transform)
        guard shown.width > 0, shown.height > 0 else { return nil }
        return shown.width / shown.height
    }
}
