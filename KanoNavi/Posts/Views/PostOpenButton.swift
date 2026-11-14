import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The button that opens a post on its platform: the X logo alone, since it
/// is X's name, or the Bilibili logo with the name unless `showsName` is
/// `false`. VoiceOver reads the platform's name either way.
struct PostOpenButton: View {
    let card: PostCard
    var showsName = true

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: open) {
            if card.isBilibili {
                let label = Label {
                    Text(DisplayCodeLabels.platform(.bilibili))
                } icon: {
                    PlatformLogo.bilibili.image
                }
                if showsName {
                    label.labelStyle(.titleAndIcon)
                } else {
                    label.labelStyle(.iconOnly)
                }
            } else {
                Label {
                    Text(.Posts.sourceX)
                } icon: {
                    PlatformLogo.x.image
                }
                .labelStyle(.iconOnly)
            }
        }
        .buttonStyle(.postOpen)
        .font(.subheadline)
    }

    private func open() {
        openURL(card.url)
    }
}
