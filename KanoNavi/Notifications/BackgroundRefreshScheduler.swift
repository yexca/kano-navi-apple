import Foundation

/// Schedules or cancels the app's background refresh task request.
nonisolated protocol BackgroundRefreshScheduler: Sendable {
    var taskIdentifier: String { get }
    /// Sets the work a scheduled refresh runs. On iOS the scene's
    /// `backgroundTask` runs it instead, so schedulers there ignore this.
    func setRefreshHandler(_ handler: @escaping @Sendable () async -> Void)
    func scheduleNextRefresh(after interval: TimeInterval) async
    func cancelRefresh()
}

nonisolated extension BackgroundRefreshScheduler {
    func setRefreshHandler(_ handler: @escaping @Sendable () async -> Void) {}
}
