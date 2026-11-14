import KanoNaviComponents
import SwiftUI

/// A video's pages as small buttons: its own platform first, then the
/// platforms of its alternates. Each opens with `openURL`.
struct VideoLinkStrip: View {
    let links: [NowLink]

    @Environment(\.openURL) private var openURL

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(links) { link in
                Button {
                    openURL(link.url)
                } label: {
                    Label {
                        Text(NowLinkButtons.title(for: link.destination))
                    } icon: {
                        NowLinkButtons.icon(for: link.destination)
                    }
                }
                .buttonStyle(.compactLink)
                .accessibilityHint(Text(verbatim: NowLink.displayHost(of: link.url)))
            }
        }
        .font(.subheadline)
    }
}
