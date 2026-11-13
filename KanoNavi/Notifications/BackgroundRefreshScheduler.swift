import Foundation

/// Schedules or cancels the app's background refresh task request.
nonisolated protocol BackgroundRefreshScheduler: Sendable {
    var taskIdentifier: String { get }
    func scheduleNextRefresh(after interval: TimeInterval) async
    func cancelRefresh()
}
