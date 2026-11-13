import BackgroundTasks
import Foundation

/// Submits `BGAppRefreshTaskRequest` using the permitted identifier declared in
/// `Info.plist`, staying aligned if a sideloading tool rewrites the bundle ID.
nonisolated struct SystemBackgroundRefreshScheduler: BackgroundRefreshScheduler {
    let taskIdentifier: String

    init(bundle: Bundle = .main) {
        if let identifiers = bundle.object(
            forInfoDictionaryKey: "BGTaskSchedulerPermittedIdentifiers"
        ) as? [String],
            let first = identifiers.first,
            !first.isEmpty
        {
            self.taskIdentifier = first
        } else {
            let bundleID = bundle.bundleIdentifier ?? "com.yexca.kanonavi"
            self.taskIdentifier = "\(bundleID).refresh"
        }
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
