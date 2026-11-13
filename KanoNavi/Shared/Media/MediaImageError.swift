import Foundation

/// Why an image could not be shown.
nonisolated enum MediaImageError: Error, Equatable, Sendable {
    /// The server does not have the file (404 `media_not_found`), or what it
    /// sent is not an image. Packaged media can be absent on a server, so a
    /// screen draws this as a state of its own; trying again does not help.
    case unavailable
    /// The file could not be fetched this time: no connection, a timeout or
    /// a server error. Trying again may work.
    case failed
}
