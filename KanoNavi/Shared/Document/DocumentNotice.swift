import Foundation

/// Why a document on screen is not a fresh read from the service.
nonisolated enum DocumentNotice: Equatable, Sendable {
    /// The document could not be loaded and nothing is on screen.
    case loadFailed
    /// A reload failed; the document read earlier stays on screen.
    case updateFailed
    /// The service could not be read, so the document is the copy cached on
    /// this device, read from the service at `fetchedAt`.
    case saved(fetchedAt: Date)
}
