import Foundation

/// Why an archive month on screen is not a fresh read from the service.
nonisolated enum ArchiveNotice: Equatable, Sendable {
    /// The month could not be loaded and nothing is on screen.
    case loadFailed
    /// A reload failed; the items loaded earlier stay on screen.
    case updateFailed
    /// The service could not be read, so the items are the copy cached on
    /// this device, read from the service at `fetchedAt`.
    case saved(fetchedAt: Date)
}
