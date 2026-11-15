import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// What the viewer shows under a post image: its description when it has
/// one, and the button that opens the post, which for a video's or GIF's
/// still plays it on X.
struct PostImageCaption: View {
    let image: PostImage
    let gallery: PostGallery

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let alt = image.alt, alt.isEmpty == false {
                Text(verbatim: alt)
                    .font(.subheadline)
            }
            Button(action: open) {
                Label {
                    Text(title)
                } icon: {
                    icon
                }
            }
            .buttonStyle(.compactLink)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: LocalizedStringResource {
        switch image.kind {
        case .video: .Posts.playVideo
        case .gif: .Posts.playGif
        case .photo, .unknown: .Posts.openPost
        }
    }

    @ViewBuilder
    private var icon: some View {
        if image.playsOnPost {
            Image(systemName: "play.fill")
        } else if gallery.isBilibili {
            PlatformLogo.bilibili.image
        } else {
            PlatformLogo.x.image
        }
    }

    private func open() {
        openURL(gallery.url)
    }
}
