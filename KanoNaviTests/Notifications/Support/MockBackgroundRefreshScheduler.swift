import Foundation
import Synchronization

@testable import KanoNavi

nonisolated final class MockBackgroundRefreshScheduler: BackgroundRefreshScheduler, Sendable {
    let taskIdentifier = "com.yexca.kanonavi.tests.refresh"
    private let state = Mutex<(scheduledCount: Int, cancelledCount: Int)>((0, 0))

    var scheduledCount: Int {
        state.withLock { $0.scheduledCount }
    }

    var cancelledCount: Int {
        state.withLock { $0.cancelledCount }
    }

    func scheduleNextRefresh(after interval: TimeInterval) async {
        state.withLock { $0.scheduledCount += 1 }
    }

    func cancelRefresh() {
        state.withLock { $0.cancelledCount += 1 }
    }
}
