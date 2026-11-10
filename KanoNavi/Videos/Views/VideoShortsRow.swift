import SwiftUI

/// The shelf's Shorts as vertical cards in a row that scrolls sideways.
struct VideoShortsRow: View {
    let cards: [VideoCard]

    @ScaledMetric(relativeTo: .body) private var cardWidth = 140

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(cards) { card in
                    VideoShortCard(card: card)
                        .frame(width: min(cardWidth, 260))
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
    }
}
