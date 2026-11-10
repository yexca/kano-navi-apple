import Foundation

/// Where `DashboardStore.snapshot` came from.
public enum DashboardSource: Equatable, Sendable {
    /// Read from the response cache at launch; no refresh has succeeded since.
    case cache
    /// Returned by a successful refresh, including a `304` that confirmed the
    /// cached body.
    case network
}
