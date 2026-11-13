import Foundation

/// One message read from `/api/dashboard/events`.
public enum RevisionStreamMessage: Equatable, Sendable {
    /// A dashboard revision number emitted on a `data:` line.
    case revision(Int)
    /// A reconnect delay in milliseconds emitted on a `retry:` line.
    case retry(milliseconds: Int)
}
