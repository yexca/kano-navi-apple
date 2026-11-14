import KanoNaviComponents
import SwiftUI

/// The identity card at the top of the Now tab, as on the web board: a
/// cropped banner, the avatar rising over its lower edge, the name, and the
/// profile's X accounts, YouTube and Bilibili.
///
/// It fills its list row edge to edge; give the row no insets and
/// ``background`` as its background, which the avatar's ring matches.
struct NowProfileCard: View {
    let profile: NowProfile

    @Environment(\.openURL) private var openURL

    /// The row's background, which the avatar's ring repeats.
    static let background = Color(.secondarySystemGroupedBackground)

    private static let bannerHeight: CGFloat = 128
    /// The avatar's size, ring included.
    private static let avatarSize: CGFloat = 84
    private static let ringWidth: CGFloat = 4
    /// Keeps the top third of the banner in view, as the web board does.
    private static let bannerAnchor = UnitPoint(x: 0.5, y: 0.3)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner
            VStack(alignment: .leading, spacing: 12) {
                avatar
                    // Half of the avatar rises over the banner.
                    .padding(.top, -Self.avatarSize / 2)
                name
                links
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private var banner: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .frame(maxWidth: .infinity)
            .frame(height: Self.bannerHeight)
            .overlay {
                if let url = profile.bannerURL {
                    MediaImage(
                        decorative: MediaImageSource(url: url), contentMode: .fill, anchor: Self.bannerAnchor)
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }

    private var avatar: some View {
        Circle()
            .fill(.fill.secondary)
            .overlay {
                if let url = profile.avatarURL {
                    MediaImage(decorative: MediaImageSource(url: url), contentMode: .fill)
                }
            }
            .frame(width: Self.avatarSize - 2 * Self.ringWidth, height: Self.avatarSize - 2 * Self.ringWidth)
            .clipShape(.circle)
            .padding(Self.ringWidth)
            .background(Self.background, in: .circle)
            .accessibilityHidden(true)
    }

    private var name: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: profile.displayName)
                .font(.title2.bold())
            if profile.romanizedName.isEmpty == false {
                Text(verbatim: profile.romanizedName)
                    .font(.caption.weight(.semibold).monospaced())
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: profile.displayName))
        .accessibilityAddTraits(.isHeader)
    }

    private var links: some View {
        NowFlowLayout(spacing: 8) {
            ForEach(profile.xAccounts) { account in
                Button {
                    openURL(account.url)
                } label: {
                    Label {
                        // A handle has no word breaks; at large text sizes it
                        // shrinks to stay whole on one line.
                        Text(verbatim: "@" + account.handle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    } icon: {
                        PlatformLogo.x.image
                    }
                }
                .accessibilityLabel(Text(.Now.profileXAccount(account.handle)))
            }
            link(to: profile.youtubeURL, title: .Now.sourceYouTube, logo: .youtube)
            if let url = profile.bilibiliURL {
                link(to: url, title: .Now.sourceBilibili, logo: .bilibili)
            }
        }
        .buttonStyle(.compactLink)
    }

    private func link(to url: URL, title: LocalizedStringResource, logo: PlatformLogo) -> some View {
        Button {
            openURL(url)
        } label: {
            Label {
                Text(title)
            } icon: {
                logo.image
            }
        }
    }
}
