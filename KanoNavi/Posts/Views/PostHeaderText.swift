import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A post's account, the agency mark for a promoted post, and its time in
/// Japan time.
struct PostHeaderText: View {
    let card: PostCard

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FlowLayout(spacing: 6) {
                PostAccountName(account: card.account)
                    .font(.subheadline.weight(.semibold))
                if card.isPromoted {
                    ComponentChip(title: .Posts.agencyPost, systemImage: "building.2", tint: .purple)
                }
            }
            Text(verbatim: JSTTimeFormat.dateTime(card.publishedAt, locale: locale))
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
