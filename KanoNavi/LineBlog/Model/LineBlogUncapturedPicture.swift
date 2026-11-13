import Foundation

/// A picture of an article that the archive never captured: only what it
/// showed and where it was.
nonisolated struct LineBlogUncapturedPicture: Hashable, Sendable {
    let alt: String?
    /// The picture's original address (provenance).
    let remoteURL: URL?
}
