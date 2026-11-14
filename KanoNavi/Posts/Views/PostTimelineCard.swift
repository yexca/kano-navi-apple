import SwiftUI

/// One post of the timeline on a card of its own, drawn as an inset grouped
/// list's section: the grouped cell background with rounded corners,
/// inset from the screen's edges.
struct PostTimelineCard: View {
    let card: PostCard

    var body: some View {
        PostCardView(card: card)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.groupedCellBackground, in: .rect(cornerRadius: 26))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}
