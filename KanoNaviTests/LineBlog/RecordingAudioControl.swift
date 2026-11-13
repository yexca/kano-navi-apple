import Synchronization

@testable import KanoNavi

/// Records what the videos asked of the audio session, in order.
nonisolated final class RecordingAudioControl: LineBlogAudioControl {
    private let recorded = Mutex<[AudioControlCall]>([])

    var calls: [AudioControlCall] {
        recorded.withLock { $0 }
    }

    func prepareForPlayback() async {
        recorded.withLock { $0.append(.prepare) }
    }

    func releaseAfterPlayback() async {
        recorded.withLock { $0.append(.release) }
    }
}
