import Foundation

/// Why the Coming Up entries are not a fresh read from the service.
enum NowComingUpNotice: Equatable {
    /// The schedule could not be read and nothing is on screen.
    case loadFailed
    /// A reload failed; the entries read earlier stay on screen.
    case updateFailed
    /// The service could not be read, so the entries are the copy cached on
    /// this device, read from the service at `fetchedAt`.
    case saved(fetchedAt: Date)
}
