import SwiftUI

/// A video row's chips, title and time.
struct VideoRowDetails: View {
    let card: VideoCard

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VideoChips(card: card)
            NowTitle(text: card.title, switchable: true)
                .font(.subheadline.weight(.semibold))
            VideoTimeText(time: card.time)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
