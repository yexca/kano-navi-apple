import KanoNaviCore
import SwiftUI

/// The mark over a video's or GIF's still: a round play button in its
/// centre, or a GIF tag in its corner. Nothing over a photo. Decorative; the
/// tile's label names the kind.
struct PostMediaKindMark: View {
    let kind: MediaKind

    @ScaledMetric(relativeTo: .title2) private var scaledDiameter = 44

    /// The play button's diameter, growing with Dynamic Type up to a limit
    /// that still leaves the still in view.
    private var diameter: CGFloat { min(scaledDiameter, 64) }

    var body: some View {
        switch kind {
        case .video:
            Image(systemName: "play.fill")
                .font(.system(size: diameter * 0.42, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: diameter, height: diameter)
                .background(.black.opacity(0.6), in: .circle)
                .accessibilityHidden(true)
        case .gif:
            Text(verbatim: "GIF")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.black.opacity(0.6), in: .rect(cornerRadius: 4))
                .padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .accessibilityHidden(true)
        case .photo, .unknown:
            EmptyView()
        }
    }

    /// What VoiceOver calls an image of this kind: "Video" or "GIF", or
    /// `nil` for a photo.
    static func name(of kind: MediaKind) -> LocalizedStringResource? {
        switch kind {
        case .video: .Posts.video
        case .gif: .Posts.gif
        case .photo, .unknown: nil
        }
    }
}
