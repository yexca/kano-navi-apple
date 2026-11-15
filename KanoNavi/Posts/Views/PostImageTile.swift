import KanoNaviCore
import SwiftUI

/// One image of a post, cropped to fill a tile of the given shape. A photo
/// opens the viewer; a video's or GIF's still carries its mark and opens the
/// post on X, where it plays. The tile counting the images not drawn opens
/// the viewer whatever it shows, since the viewer reaches them.
struct PostImageTile: View {
    let image: PostImage
    let aspectRatio: CGFloat
    /// Images not drawn after this one, shown as `+N` over it.
    let hiddenCount: Int
    /// Opens the viewer on this image.
    let open: () -> Void
    /// Opens the post where its video or GIF plays.
    let play: () -> Void

    private var plays: Bool { image.playsOnPost && hiddenCount == 0 }

    var body: some View {
        Button(action: plays ? play : open) {
            Rectangle()
                .fill(.fill.tertiary)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay {
                    MediaImage(decorative: image.source, contentMode: .fill)
                }
                .overlay {
                    if hiddenCount > 0 {
                        Text(.Posts.moreImages(hiddenCount))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.45))
                    } else {
                        PostMediaKindMark(kind: image.kind)
                    }
                }
                .clipShape(.rect(cornerRadius: 8))
                .contentShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        // Keep the height the width gives; a List row placing the row
        // at its measured height must not squeeze the image narrower.
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel(Self.label(of: image))
        .accessibilityAddTraits(.isImage)
        .accessibilityHint(Text(hint))
    }

    /// What VoiceOver reads for an image, here and in the viewer: its
    /// description, after "Video" or "GIF" for a still; without one, what
    /// it is.
    static func label(of image: PostImage) -> Text {
        let kind = PostMediaKindMark.name(of: image.kind)
        if let alt = image.alt, alt.isEmpty == false {
            if let kind {
                return Text(.Posts.mediaWithDescription(String(localized: kind), alt))
            }
            return Text(verbatim: alt)
        }
        return Text(kind ?? .Posts.image)
    }

    private var hint: LocalizedStringResource {
        guard plays else { return .Posts.openImageHint }
        return image.kind == .gif ? .Posts.playGif : .Posts.playVideo
    }
}
