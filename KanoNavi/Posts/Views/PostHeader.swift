import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A post's avatar, its account, the agency mark for a promoted post, its
/// time in Japan time, and the button that opens it in the trailing corner.
/// A Bilibili button drops its name when the line has no room for it.
struct PostHeader: View {
    let card: PostCard

    var body: some View {
        if card.isBilibili {
            ViewThatFits(in: .horizontal) {
                PostHeaderRow(card: card, showsOpenName: true)
                PostHeaderRow(card: card, showsOpenName: false)
            }
        } else {
            PostHeaderRow(card: card, showsOpenName: false)
        }
    }
}
