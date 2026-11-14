import Foundation

#if os(iOS)
    import BackgroundTasks

    /// Submits `BGAppRefreshTaskRequest` using the permitted identifier declared in
    /// `Info.plist`, staying aligned if a sideloading tool rewrites the bundle ID.
    nonisolated struct SystemBackgroundRefreshScheduler: BackgroundRefreshScheduler {
        let taskIdentifier: String

        init(bundle: Bundle = .main) {
            taskIdentifier = BackgroundRefreshIdentifier.identifier(in: bundle)
        }

        func scheduleNextRefresh(after interval: TimeInterval = 15 * 60) async {
            let identifier = taskIdentifier
            await Task.detached(priority: .utility) {
                let request = BGAppRefreshTaskRequest(identifier: identifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: max(60, interval))
                if #available(iOS 27.0, *) {
                    try? await BGTaskScheduler.shared.submitTaskRequest(request)
                } else {
                    try? BGTaskScheduler.shared.submit(request)
                }
            }.value
        }

        func cancelRefresh() {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        }
    }
#else
    import Synchronization

    /// Runs the refresh handler once through `NSBackgroundActivityScheduler`,
    /// which picks a moment that suits the Mac's energy use, while the app
    /// runs (with or without a window). Each run schedules the next one, as
    /// on iOS.
    nonisolated final class SystemBackgroundRefreshScheduler: BackgroundRefreshScheduler {
        let taskIdentifier: String
        private let state = Mutex(State())

        private struct State {
            var activity: NSBackgroundActivityScheduler?
            var handler: (@Sendable () async -> Void)?
        }

        init(bundle: Bundle = .main) {
            taskIdentifier = BackgroundRefreshIdentifier.identifier(in: bundle)
        }

        func setRefreshHandler(_ handler: @escaping @Sendable () async -> Void) {
            state.withLock { $0.handler = handler }
        }

        /// Runs no earlier than `interval` from now, as a
        /// `BGAppRefreshTaskRequest`'s earliest begin date, and at the latest
        /// half as long again after it.
        func scheduleNextRefresh(after interval: TimeInterval = 15 * 60) async {
            let delay = max(60, interval)
            let identifier = taskIdentifier
            state.withLock { state in
                state.activity?.invalidate()
                guard let handler = state.handler else {
                    state.activity = nil
                    return
                }
                let activity = NSBackgroundActivityScheduler(identifier: identifier)
                activity.repeats = false
                activity.interval = delay * 1.25
                activity.tolerance = delay * 0.25
                activity.qualityOfService = .utility
                activity.schedule { completion in
                    Task {
                        await handler()
                        completion(.finished)
                    }
                }
                state.activity = activity
            }
        }

        func cancelRefresh() {
            state.withLock { state in
                state.activity?.invalidate()
                state.activity = nil
            }
        }
    }
#endif

/// The background refresh's identifier: the first permitted identifier in
/// `Info.plist`, or `<bundle-id>.refresh`.
private nonisolated enum BackgroundRefreshIdentifier {
    static func identifier(in bundle: Bundle) -> String {
        if let identifiers = bundle.object(forInfoDictionaryKey: "BGTaskSchedulerPermittedIdentifiers")
            as? [String],
            let first = identifiers.first,
            !first.isEmpty
        {
            return first
        }
        let bundleID = bundle.bundleIdentifier ?? "com.yexca.kanonavi"
        return "\(bundleID).refresh"
    }
}
