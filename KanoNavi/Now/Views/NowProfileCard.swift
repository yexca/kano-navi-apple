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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The row's background, which the avatar's ring repeats.
    static let background = Color.groupedCellBackground

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

    /// The links in one row: the X handles, then YouTube and Bilibili as
    /// round logo buttons. A row too wide for the card is tried with tighter
    /// spacing, between the buttons and between each X logo and its handle,
    /// then at the extra large and large text sizes; past that the handles
    /// shrink to keep the row. Only at accessibility text sizes do the links
    /// wrap instead.
    private var links: some View {
        ViewThatFits(in: .horizontal) {
            linkRow(spacing: 8)
            linkRow(spacing: 4, logoSpacing: 4)
            if dynamicTypeSize.isAccessibilitySize {
                NowFlowLayout(spacing: 8) {
                    linkButtons()
                }
            } else {
                linkRow(spacing: 4, logoSpacing: 4)
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                linkRow(spacing: 4, logoSpacing: 4)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                HStack(spacing: 4) {
                    linkButtons(logoSpacing: 4)
                }
            }
        }
    }

    /// The links in one row, none of them shrunk.
    private func linkRow(spacing: CGFloat, logoSpacing: CGFloat? = nil) -> some View {
        HStack(spacing: spacing) {
            linkButtons(logoSpacing: logoSpacing)
        }
        .fixedSize()
    }

    /// The links' buttons, small except at accessibility text sizes.
    /// - Parameter logoSpacing: The gap between each X logo and its handle;
    ///   `nil` keeps the label's own.
    private func linkButtons(logoSpacing: CGFloat? = nil) -> some View {
        Group {
            ForEach(profile.xAccounts) { account in
                Button {
                    openURL(account.url)
                } label: {
                    handleLabel(account.handle, logoSpacing: logoSpacing)
                }
                .accessibilityLabel(Text(.Now.profileXAccount(account.handle)))
            }
            logoLink(to: profile.youtubeURL, title: .Now.sourceYouTube, logo: .youtube)
            if let url = profile.bilibiliURL {
                logoLink(to: url, title: .Now.sourceBilibili, logo: .bilibili)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(dynamicTypeSize.isAccessibilitySize ? .regular : .small)
    }

    @ViewBuilder
    private func handleLabel(_ handle: String, logoSpacing: CGFloat?) -> some View {
        // A handle has no word breaks; when the links do not fit at their
        // full size it shrinks to stay whole on one line.
        let text = Text(verbatim: "@" + handle)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        if let logoSpacing {
            HStack(spacing: logoSpacing) {
                PlatformLogo.x.image
                text
            }
        } else {
            Label {
                text
            } icon: {
                PlatformLogo.x.image
            }
            .labelStyle(.titleAndIcon)
        }
    }

    /// A round button showing only the platform's logo, by the user's choice
    /// for this card; VoiceOver reads the platform's name from the label.
    private func logoLink(to url: URL, title: LocalizedStringResource, logo: PlatformLogo) -> some View {
        Button {
            openURL(url)
        } label: {
            Label {
                Text(title)
            } icon: {
                logo.image
            }
            .labelStyle(.iconOnly)
        }
        .buttonBorderShape(.circle)
    }
}
