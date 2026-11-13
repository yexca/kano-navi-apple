import Foundation

/// Why a revision stream ended or could not be opened.
public enum RevisionStreamError: Error, Equatable, Sendable {
    /// The server rejected or disabled the stream (such as HTTP 503) and may
    /// have supplied a `Retry-After` delay in seconds.
    case unavailable(retryAfter: TimeInterval?)
    /// The connection failed or closed.
    case disconnected
}
