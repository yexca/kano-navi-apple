import KanoNaviCore

/// A non-blocking problem shown beside the last good data.
enum NowStatus: Equatable {
    /// The service sends a dashboard this app version cannot read.
    case serviceNeedsUpdate
    case offline
    case serverError(status: Int)
    case unreadable

    /// The status for the store's state, or `nil` when there is nothing to
    /// report.
    init?(phase: DashboardPhase, isIncompatible: Bool) {
        if isIncompatible {
            self = .serviceNeedsUpdate
            return
        }
        guard case .failed(let error) = phase else { return nil }
        switch error {
        case .offline: self = .offline
        case .http(let status): self = .serverError(status: status)
        case .decoding: self = .unreadable
        case .incompatible: self = .serviceNeedsUpdate
        case .cancelled: return nil
        }
    }
}
