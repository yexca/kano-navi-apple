import KanoNaviCore
import SwiftUI

/// One post: who wrote it and when, its text in the content language, its
/// images, the post it quotes and a button to open the original.
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
                Label {
                    Text(card.isBilibili ? .Posts.openOnBilibili : .Posts.openOnX)
                } icon: {
                    Image(systemName: "arrow.up.right.square")
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
