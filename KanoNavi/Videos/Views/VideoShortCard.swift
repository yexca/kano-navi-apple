import SwiftUI

/// A Short as a vertical card: a 9:16 cover with its title and time below.
/// The whole card opens the Short.
struct VideoShortCard: View {
    let card: VideoCard

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 6) {
                VideoThumbnail(url: card.thumbnailURL, aspectRatio: 9 / 16, lengthText: card.lengthText)
                VideoChips(card: card)
                NowTitle(text: card.title)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                VideoTimeText(time: card.time)
                    .font(.footnote)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text(link.map { NowLinkButtons.title(for: $0.destination) } ?? .Videos.watch))
    }

    private var link: NowLink? { card.links.first }

    private func open() {
        if let link {
            openURL(link.url)
        }
    }
}
