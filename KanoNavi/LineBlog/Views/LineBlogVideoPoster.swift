import SwiftUI

/// A video before it plays: its cover, or a dark frame without one, with a
/// play button when the archive holds a copy.
struct LineBlogVideoPoster: View {
    let cover: MediaImageSource?
    let isPlayable: Bool
    let isPreparing: Bool
    let play: () -> Void

    var body: some View {
        if isPlayable {
            Button(action: play) {
                picture
                    .overlay {
                        if isPreparing {
                            ProgressView()
                                .controlSize(.large)
                                .tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.55), in: .circle)
                                .overlay {
                                    Circle()
                                        .stroke(.white.opacity(0.7), lineWidth: 1.5)
                                }
                        }
                    }
            }
            .buttonStyle(.plain)
            .disabled(isPreparing)
            .accessibilityLabel(Text(isPreparing ? .LineBlog.videoPreparing : .LineBlog.playVideo))
        } else {
            picture
        }
    }

    private var picture: some View {
        Color.black
            .aspectRatio(LineBlogVideoGeometry.defaultAspectRatio, contentMode: .fit)
            .overlay {
                if let cover {
                    // A cover is a 4:3 still with bars above and below the
                    // 16:9 picture: filling the frame, the bars fall
                    // outside it.
                    MediaImage(decorative: cover, contentMode: .fill)
                }
            }
            .clipped()
    }
}
