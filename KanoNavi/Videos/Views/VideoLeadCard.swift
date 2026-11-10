import SwiftUI

/// The shelf's lead: a large cover, its chips, title, time and links.
struct VideoLeadCard: View {
    let card: VideoCard
    let isFeatured: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VideoThumbnail(url: card.thumbnailURL, lengthText: card.lengthText)
            VideoChips(card: card, isFeatured: isFeatured)
            NowTitle(text: card.title, switchable: true)
                .font(.headline)
            VideoTimeText(time: card.time)
                .font(.subheadline)
            NowLinkButtons(links: card.links)
        }
        .padding(.vertical, 8)
        // Take the height the content needs; a List row placed at a smaller
        // height would squeeze wrapped text to one truncated line.
        .fixedSize(horizontal: false, vertical: true)
    }
}
