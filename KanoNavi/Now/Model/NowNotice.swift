import KanoNaviCore

/// What the Now tab says above its data when the data is not a fresh read.
enum NowNotice: Equatable {
    /// The last refresh failed. `isSavedCopy` is `true` when the data on
    /// screen is the snapshot saved on this device, which never refreshed.
    case failed(NowStatus, isSavedCopy: Bool)
    /// The data is the snapshot saved on this device and has not refreshed
    /// yet; `isUpdating` while a refresh runs.
    case savedCopy(isUpdating: Bool)

    /// The notice for the store's state, or `nil` when the data on screen
    /// came from the service and nothing failed.
    init?(source: DashboardSource?, phase: DashboardPhase, isIncompatible: Bool) {
        let isSavedCopy = source == .cache
        if let status = NowStatus(phase: phase, isIncompatible: isIncompatible) {
            self = .failed(status, isSavedCopy: isSavedCopy)
        } else if isSavedCopy {
            self = .savedCopy(isUpdating: phase == .refreshing || phase == .loading)
        } else {
            return nil
        }
    }
}
