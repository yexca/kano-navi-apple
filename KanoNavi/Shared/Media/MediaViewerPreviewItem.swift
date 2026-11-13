import Foundation

/// A stand-in picture for the viewer's previews.
nonisolated struct MediaViewerPreviewItem: Identifiable, Sendable {
    let id: Int
    let url: URL
}
