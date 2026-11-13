import Foundation

/// Keeps the reader's videos to one at a time and the audio session to
/// the time a video plays.
///
/// Every video of the app reports here: starting one pauses the one that
/// was playing, and when the last one stops, the audio session is given
/// back after a short wait, so music the video interrupted carries on. The
/// wait covers a pause that is followed at once by play, such as a seek or
/// a switch from one video to the next.
final class LineBlogVideoCoordinator {
    /// The app's coordinator.
    static let shared = LineBlogVideoCoordinator(audio: LineBlogAudioSession())

    private let audio: any LineBlogAudioControl
    private let releaseDelay: Duration
    /// The video that plays now.
    private weak var current: (any LineBlogVideoPlayer)?
    /// The pending hand-back of the audio session; `nil` when none waits.
    private(set) var release: Task<Void, Never>?

    init(audio: any LineBlogAudioControl, releaseDelay: Duration = .milliseconds(400)) {
        self.audio = audio
        self.releaseDelay = releaseDelay
    }

    /// Call before `player` starts: pauses the video that plays and takes
    /// the audio session for this one.
    func willPlay(_ player: any LineBlogVideoPlayer) async {
        makeCurrent(player)
        await audio.prepareForPlayback()
    }

    /// Call when `player` plays again on its own, such as from the
    /// player's own controls.
    func didResume(_ player: any LineBlogVideoPlayer) {
        makeCurrent(player)
    }

    /// Call when `player` stops: paused, ended, withdrawn or gone from the
    /// screen. Only the video that plays now counts.
    func didStop(_ player: any LineBlogVideoPlayer) {
        guard current === player else { return }
        current = nil
        release?.cancel()
        release = Task { [audio, releaseDelay] in
            try? await Task.sleep(for: releaseDelay)
            guard Task.isCancelled == false else { return }
            await audio.releaseAfterPlayback()
        }
    }

    private func makeCurrent(_ player: any LineBlogVideoPlayer) {
        // The new video is current before the old one is paused, so the
        // old one's report that it stopped does not give the session back.
        let previous = current
        current = player
        if let previous, previous !== player {
            previous.pause()
        }
        release?.cancel()
        release = nil
    }
}
