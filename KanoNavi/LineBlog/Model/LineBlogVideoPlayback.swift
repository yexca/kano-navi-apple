import AVFoundation
import Observation
import VideoToolbox

/// The playback of one archived video file: nothing is fetched until the
/// reader asks to play it.
@Observable
final class LineBlogVideoPlayback {
    /// Where the playback stands.
    enum Phase: Equatable {
        /// Not started: the cover and a play button.
        case poster
        /// The file is being opened.
        case preparing
        /// The player is on screen.
        case playing
        /// The file could not be opened.
        case failed
    }

    private(set) var phase = Phase.poster
    private(set) var player: AVPlayer?
    /// Width over height of the picture, read from the stream: the API
    /// does not state a video's size.
    private(set) var aspectRatio: CGFloat = LineBlogVideoGeometry.defaultAspectRatio

    /// Counts the starts and the withdrawals, so a file that finishes
    /// opening after the reader left it is not played.
    private var attempt = 0

    /// Opens the file, sizes the player from its video track and plays.
    /// A file whose picture this device cannot decode fails, as one that
    /// cannot be opened does.
    func play(_ url: URL) async {
        guard phase == .poster || phase == .failed else { return }
        attempt += 1
        let attempt = attempt
        phase = .preparing
        Self.registerSupplementalDecoders()
        let asset = AVURLAsset(url: url)
        do {
            var isPlayable = try await asset.load(.isPlayable)
            if isPlayable, let track = try await asset.loadTracks(withMediaType: .video).first {
                let (size, transform, isDecodable) = try await track.load(
                    .naturalSize, .preferredTransform, .isDecodable)
                isPlayable = isDecodable
                aspectRatio =
                    LineBlogVideoGeometry.aspectRatio(naturalSize: size, transform: transform) ?? aspectRatio
            }
            guard attempt == self.attempt else { return }
            guard isPlayable else {
                phase = .failed
                return
            }
            // A video the reader started plays its sound even with the
            // ring switch off.
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            self.player = player
            phase = .playing
            player.play()
        } catch {
            guard attempt == self.attempt else { return }
            phase = .failed
        }
    }

    /// Some archived copies are VP9, which the system decodes only for an
    /// app that asks for it, and only from iOS 26.2. Before that such a copy
    /// is not playable and the block says so beside its watch link.
    private static func registerSupplementalDecoders() {
        if #available(iOS 26.2, *) {
            VTRegisterSupplementalVideoDecoderIfAvailable(kCMVideoCodecType_VP9)
        }
    }

    /// Pauses when the video leaves the screen. A file still being opened
    /// goes back to its cover and does not start.
    func pause() {
        if phase == .preparing {
            attempt += 1
            phase = .poster
        }
        player?.pause()
    }
}
