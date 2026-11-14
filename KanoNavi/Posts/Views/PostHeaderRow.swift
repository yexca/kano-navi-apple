import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One layout of a post's header. At accessibility text sizes the account
/// and time take their own lines under the avatar and the open button, so a
/// long handle is not squeezed between them.
struct PostHeaderRow: View {
    let card: PostCard
    /// Whether a Bilibili open button shows the platform's name.
    let showsOpenName: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    PostAvatarView(avatar: card.avatar)
                    Spacer(minLength: 8)
                    PostOpenButton(card: card, showsName: showsOpenName)
                        .padding(.vertical, -6)
                }
                PostHeaderText(card: card)
            }
        } else {
            HStack(alignment: .top, spacing: 10) {
                PostAvatarView(avatar: card.avatar)
                PostHeaderText(card: card)
                    .frame(maxWidth: .infinity, alignment: .leading)
                PostOpenButton(card: card, showsName: showsOpenName)
                    // The capsule lines up with the avatar's top; its taller
                    // hit area reaches into the row's padding.
                    .padding(.vertical, -6)
            }
        }
    }
}
