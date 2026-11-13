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

    /// Opens the file, sizes the player from its video track and plays.
    func play(_ url: URL) async {
        guard phase == .poster || phase == .failed else { return }
        phase = .preparing
        Self.registerSupplementalDecoders()
        let asset = AVURLAsset(url: url)
        do {
            guard try await asset.load(.isPlayable) else {
                phase = .failed
                return
            }
            if let track = try await asset.loadTracks(withMediaType: .video).first {
                let (size, transform) = try await track.load(.naturalSize, .preferredTransform)
                aspectRatio =
                    LineBlogVideoGeometry.aspectRatio(naturalSize: size, transform: transform) ?? aspectRatio
            }
            // A video the reader started plays its sound even with the
            // ring switch off.
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            self.player = player
            phase = .playing
            player.play()
        } catch {
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

    /// Pauses when the video leaves the screen.
    func pause() {
        player?.pause()
    }
}
