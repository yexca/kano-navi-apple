@testable import KanoNavi

/// A video that reports to its coordinator the way the real one does: a
/// pause is followed by its report that it stopped.
final class StubVideoPlayer: LineBlogVideoPlayer {
    private let coordinator: LineBlogVideoCoordinator
    private(set) var pauseCount = 0

    init(coordinator: LineBlogVideoCoordinator) {
        self.coordinator = coordinator
    }

    func pause() {
        pauseCount += 1
        coordinator.didStop(self)
    }
}
