import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One post: who wrote it and when, its text in the content language, its
/// images, the post it quotes and a button that opens the original: the X
/// logo alone, or the Bilibili logo and name.
struct PostCardView: View {
    let card: PostCard

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PostHeader(card: card)
            if let text = card.text {
                NowTitle(text: text, switchable: true)
            }
            PostImageGrid(images: card.images)
            if let quote = card.quote {
                PostQuoteView(quote: quote)
            }
            Button(action: open) {
                if card.isBilibili {
                    Label {
                        Text(DisplayCodeLabels.platform(.bilibili))
                    } icon: {
                        PlatformLogo.bilibili.image
                    }
                } else {
                    // X's logo is its name, so the logo stands alone;
                    // VoiceOver still reads "X".
                    Label {
                        Text(.Posts.sourceX)
                    } icon: {
                        PlatformLogo.x.image
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .buttonStyle(.compactLink)
            .font(.subheadline)
        }
        .padding(.vertical, 6)
        // Take the height the content needs; a List row placed at a smaller
        // height would squeeze wrapped text to one truncated line.
        .fixedSize(horizontal: false, vertical: true)
    }

    private func open() {
        openURL(card.url)
    }
}
