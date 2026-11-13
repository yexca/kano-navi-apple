import Foundation

/// A pictograph of the blog's own set: a small picture drawn inside the text
/// at text size.
nonisolated struct LineBlogPictograph: Hashable, Sendable {
    /// The archived file, or `nil` for a pictograph the archive never
    /// captured.
    let source: MediaImageSource?
    /// What the pictograph shows, read by VoiceOver and drawn in its place
    /// when the file cannot be shown.
    let alt: String?
}
