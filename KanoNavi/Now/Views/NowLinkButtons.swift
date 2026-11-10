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
                Image(systemName: Self.symbol(for: link.destination))
            }
        }
        .labelStyle(.titleAndIcon)
        .accessibilityHint(Text(verbatim: NowLink.displayHost(of: link.url)))
    }

    static func title(for destination: NowLink.Destination) -> LocalizedStringResource {
        switch destination {
        case .platform(let platform):
            .Now.openOnPlatform(String(localized: DisplayCodeLabels.platform(platform)))
        case .site(let host):
            .Now.openSite(host)
        case .announcement:
            .Now.openAnnouncement
        }
    }

    static func symbol(for destination: NowLink.Destination) -> String {
        switch destination {
        case .platform(.youtube): "play.rectangle.fill"
        case .platform: "play.tv"
        case .site: "safari"
        case .announcement: "megaphone"
        }
    }
}
