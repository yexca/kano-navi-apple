import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One post: its header with the avatar, who wrote it and when, and the
/// button that opens the original; then its text in the content language,
/// its images and the post it quotes.
struct PostCardView: View {
    let card: PostCard
    /// Opens the viewer over the post's or the quote's images.
    let openImage: (PostGallery, PostImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PostHeader(card: card)
            if let text = card.text {
                NowTitle(text: text, switchable: true)
            }
            PostImageGrid(gallery: card.gallery, open: openImage)
            if let quote = card.quote {
                PostQuoteView(quote: quote, openImage: openImage)
            }
        }
        .padding(.vertical, 6)
        // Take the height the content needs; a List row placed at a smaller
        // height would squeeze wrapped text to one truncated line.
        .fixedSize(horizontal: false, vertical: true)
    }
}
