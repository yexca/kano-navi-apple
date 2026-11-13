import AVKit
import SwiftUI

/// A video of an article. A downloaded copy plays in place from the
/// service's own file once the reader presses play; without a copy the
/// block shows the cover alone. The YouTube page and its archived capture
/// are links under it, opened only on request.
struct LineBlogVideoView: View {
    let video: LineBlogVideoEmbed

    @State private var playback = LineBlogVideoPlayback()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if video.file != nil || video.cover != nil {
                frame
                    .clipShape(.rect(cornerRadius: 10))
            }
            if playback.phase == .failed {
                Label {
                    Text(.LineBlog.videoUnavailable)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            } else if video.file == nil {
                Text(.LineBlog.videoNoCopy)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let url = video.watchURL {
                LineBlogProvenanceLink(title: .LineBlog.watchOnYouTube, url: url)
            }
            if let url = video.archiveURL {
                LineBlogProvenanceLink(title: .LineBlog.archivedCapture, url: url)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onDisappear(perform: playback.pause)
        .onScrollVisibilityChange(threshold: 0.01) { isVisible in
            if isVisible == false {
                playback.pause()
            }
        }
    }

    @ViewBuilder private var frame: some View {
        if playback.phase == .playing, let player = playback.player {
            VideoPlayer(player: player)
                .aspectRatio(playback.aspectRatio, contentMode: .fit)
        } else {
            LineBlogVideoPoster(
                cover: video.cover, isPlayable: video.file != nil, isPreparing: playback.phase == .preparing,
                play: play)
        }
    }

    private func play() {
        guard let file = video.file else { return }
        Task { await playback.play(file) }
    }
}
