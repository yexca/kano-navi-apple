import Foundation

/// Why the month on screen is not a fresh read from the service.
enum ScheduleNotice: Equatable {
    /// The month could not be loaded and nothing is on screen.
    case loadFailed
    /// A reload failed; the month loaded earlier stays on screen.
    case updateFailed
    /// The service could not be read, so the month is the copy cached on
    /// this device, read from the service at `fetchedAt` when known.
    case saved(fetchedAt: Date?)
}
