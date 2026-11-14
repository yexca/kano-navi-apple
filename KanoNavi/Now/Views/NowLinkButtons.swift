import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A card's external links. The first is the prominent one.
struct NowLinkButtons: View {
    let links: [NowLink]

    @Environment(\.openURL) private var openURL

    var body: some View {
        NowFlowLayout(spacing: 8) {
            ForEach(links.enumerated(), id: \.element.id) { index, link in
                if index == 0 {
                    button(for: link)
                        .buttonStyle(.borderedProminent)
                } else {
                    button(for: link)
                        .buttonStyle(.bordered)
                }
            }
        }
    }

    private func button(for link: NowLink) -> some View {
        Button {
            openURL(link.url)
        } label: {
            Label {
                Text(Self.title(for: link.destination))
            } icon: {
                Self.icon(for: link.destination)
            }
        }
        .labelStyle(.titleAndIcon)
        .accessibilityHint(Text(verbatim: NowLink.displayHost(of: link.url)))
    }

    static func title(for destination: NowLink.Destination) -> LocalizedStringResource {
        switch destination {
        case .platform(let platform):
            DisplayCodeLabels.platform(platform)
        case .site(let host):
            .Now.openSite(host)
        case .announcement:
            .Now.openAnnouncement
        }
    }

    /// A platform page shows the platform's logo; a site or an
    /// announcement shows a symbol.
    static func icon(for destination: NowLink.Destination) -> Image {
        switch destination {
        case .platform(let platform): PlatformMark.image(for: platform)
        case .site: Image(systemName: "safari")
        case .announcement: Image(systemName: "megaphone")
        }
    }
}
