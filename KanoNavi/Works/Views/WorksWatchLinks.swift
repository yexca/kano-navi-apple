import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The pages a recording can be watched on, as small buttons in the web
/// board's order: niconico, YouTube, members-only YouTube, Bilibili. Each
/// opens in the browser; the app never loads the page.
struct WorksWatchLinks: View {
    let links: [WorksUploadLink]
    /// The song or track, for VoiceOver.
    let title: String

    @Environment(\.openURL) private var openURL

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(links) { item in
                Button {
                    openURL(item.link.url)
                } label: {
                    Label {
                        Text(Self.name(for: item.link))
                            .strikethrough(item.isGone)
                    } icon: {
                        Image(systemName: Self.symbol(for: item.link))
                    }
                }
                .buttonStyle(.compactLink)
                .accessibilityLabel(Text(Self.spokenLabel(for: item, title: title)))
            }
        }
        .font(.subheadline)
    }

    /// The button's title: the platform, marked when only channel members
    /// can watch.
    nonisolated static func name(for link: PlatformVideoLink) -> LocalizedStringResource {
        let platform = String(localized: WorksCodeLabels.platform(link.platform))
        return link.isMembersOnly
            ? .Works.watchMembersOnly(platform) : WorksCodeLabels.platform(link.platform)
    }

    nonisolated static func symbol(for link: PlatformVideoLink) -> String {
        if link.isMembersOnly { return "person.badge.key.fill" }
        return switch link.platform {
        case .niconico: "play.tv.fill"
        case .youtube: "play.rectangle.fill"
        case .bilibili: "tv.fill"
        }
    }

    /// What VoiceOver reads: what is watched, where, and that it is gone
    /// when the stored data says so.
    nonisolated static func spokenLabel(for item: WorksUploadLink, title: String) -> LocalizedStringResource {
        let name = String(localized: name(for: item.link))
        return item.isGone ? .Works.watchOnGone(title, name) : .Works.watchOn(title, name)
    }
}
