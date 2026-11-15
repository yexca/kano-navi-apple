import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The identity card at the top of the Now tab, as on the web board: a
/// cropped banner, the avatar rising over its lower edge, the tagline, the
/// name, the catchphrase, the profile's X accounts, YouTube and Bilibili, and
/// the dashboard's counts. The banner and the avatar open the viewer.
///
/// In a compact width it is the web board's phone card, so the board below
/// comes up sooner: a shorter banner, a smaller avatar with the name beside
/// it, the catchphrase under them, and no tagline.
///
/// It fills its list row edge to edge; give the row no insets and
/// ``background`` as its background, which the avatar's ring matches.
struct NowProfileCard: View {
    let profile: NowProfile

    @Environment(\.openURL) private var openURL
    @Environment(AppRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The image the viewer opens on; `nil` while it is closed.
    @State private var openedPicture: NowPicture?

    /// The row's background, which the avatar's ring repeats.
    static let background = Color.groupedCellBackground

    /// Keeps the top third of the banner in view, as the web board does.
    private static let bannerAnchor = UnitPoint(x: 0.5, y: 0.3)

    /// The card's measures in a regular and a compact width, the web board's
    /// wide and phone cards.
    private struct Metrics {
        var bannerHeight: CGFloat
        /// The avatar's size, ring included.
        var avatarSize: CGFloat
        var ringWidth: CGFloat

        static let regular = Metrics(bannerHeight: 128, avatarSize: 84, ringWidth: 4)
        static let compact = Metrics(bannerHeight: 88, avatarSize: 64, ringWidth: 3)
    }

    /// Whether the card takes its compact form. A Mac window has no size
    /// class and keeps the regular one.
    private var isCompact: Bool { horizontalSizeClass == .compact }

    private var metrics: Metrics { isCompact ? .compact : .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner
            if isCompact {
                compactBody
            } else {
                regularBody
            }
        }
        .mediaViewer(item: $openedPicture, in: NowPicture.profile(profile)) { picture in
            MediaImageSource(url: picture.url)
        } label: { picture in
            Text(picture.role.name)
        } caption: { [displayName = profile.displayName] picture in
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: displayName)
                    .font(.headline)
                Text(picture.role.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var regularBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            avatar
                // Half of the avatar rises over the banner.
                .padding(.top, -metrics.avatarSize / 2)
            VStack(alignment: .leading, spacing: 4) {
                // Japanese copy in every language, in the Japanese face.
                Text(.Now.profileTagline)
                    .font(.japanese(.caption))
                    .foregroundStyle(.berry)
                    // Wraps rather than truncates at accessibility sizes.
                    .fixedSize(horizontal: false, vertical: true)
                name
            }
            catchphrase
            links
            if let counts = profile.counts {
                countsRow(counts)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    /// The avatar on the left with the name beside it, then the catchphrase,
    /// the links and the counts across the card. At accessibility text sizes
    /// the name goes under the avatar, where it has the card's width.
    private var compactBody: some View {
        let identity =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
        return VStack(alignment: .leading, spacing: 10) {
            identity {
                avatar
                    // Half of the avatar rises over the banner, past the
                    // body's top padding.
                    .padding(.top, -(metrics.avatarSize / 2 + Self.compactTopPadding))
                compactName
            }
            catchphrase
            links
            if let counts = profile.counts {
                countsRow(counts)
            }
        }
        .padding(.top, Self.compactTopPadding)
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private static let compactTopPadding: CGFloat = 8

    private var catchphrase: some View {
        Text(.Now.profileCatchphrase)
            .font(.japanese(.subheadline))
            .foregroundStyle(.berry)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var banner: some View {
        opener(for: .banner, url: profile.bannerURL) {
            Rectangle()
                .fill(.fill.tertiary)
                .frame(maxWidth: .infinity)
                .frame(height: metrics.bannerHeight)
                .overlay {
                    if let url = profile.bannerURL {
                        MediaImage(
                            decorative: MediaImageSource(url: url), contentMode: .fill,
                            anchor: Self.bannerAnchor)
                    }
                }
                .clipped()
                .contentShape(.rect)
        }
    }

    private var avatar: some View {
        opener(for: .avatar, url: profile.avatarURL) {
            Circle()
                .fill(.fill.secondary)
                .overlay {
                    if let url = profile.avatarURL {
                        MediaImage(decorative: MediaImageSource(url: url), contentMode: .fill)
                    }
                }
                .frame(
                    width: metrics.avatarSize - 2 * metrics.ringWidth,
                    height: metrics.avatarSize - 2 * metrics.ringWidth
                )
                .clipShape(.circle)
                .padding(metrics.ringWidth)
                .background(Self.background, in: .circle)
                .contentShape(.circle)
        }
    }

    /// The banner or the avatar as a button that opens the viewer on it; the
    /// bare fill, hidden from VoiceOver, while the profile has no such image.
    @ViewBuilder
    private func opener(
        for role: NowPicture.Role, url: URL?, @ViewBuilder label: () -> some View
    ) -> some View {
        if let url {
            Button {
                openedPicture = NowPicture(role: role, url: url)
            } label: {
                label()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(role.name))
            .accessibilityAddTraits(.isImage)
            .accessibilityHint(Text(.Now.openImageHint))
        } else {
            label()
                .accessibilityHidden(true)
        }
    }

    private var name: some View {
        nameElement(
            VStack(alignment: .leading, spacing: 4) {
                displayName
                romanizedName
            })
    }

    /// The romanized name after the name on one line, as on the web board's
    /// phone card, or under it when the line is too narrow.
    private var compactName: some View {
        nameElement(
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    displayName
                    romanizedName
                }
                VStack(alignment: .leading, spacing: 2) {
                    displayName
                    romanizedName
                }
            })
    }

    /// The name as one heading that VoiceOver reads without the romanized
    /// name.
    private func nameElement(_ content: some View) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: profile.displayName))
            .accessibilityAddTraits(.isHeader)
    }

    private var displayName: some View {
        Text(verbatim: profile.displayName)
            .font(.title2.bold())
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var romanizedName: some View {
        if profile.romanizedName.isEmpty == false {
            Text(verbatim: profile.romanizedName)
                .font(.caption.weight(.semibold).monospaced())
                .textCase(.uppercase)
                .tracking(2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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

    /// The counts in one row, wrapping only at accessibility text sizes.
    @ViewBuilder
    private func countsRow(_ counts: NowProfile.Counts) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            NowFlowLayout(spacing: 20) {
                countButtons(counts)
            }
        } else {
            HStack(spacing: 20) {
                countButtons(counts)
            }
        }
    }

    /// Upcoming entries, posts and videos, each opening its tab: Schedule on
    /// today, Posts and Videos at their newest.
    private func countButtons(_ counts: NowProfile.Counts) -> some View {
        Group {
            countButton(
                counts.upcomingEvents, systemImage: "calendar",
                label: .Now.profileUpcomingCount(counts.upcomingEvents)
            ) {
                router.selectedTab = .schedule
                router.scheduleFocus = .date(JapanDate.today(at: .now))
            }
            countButton(
                counts.posts, systemImage: "bubble.left",
                label: .Now.profilePostCount(count: counts.posts, days: counts.postWindowDays)
            ) {
                router.selectedTab = .posts
            }
            countButton(
                counts.videos, systemImage: "play.rectangle",
                label: .Now.profileVideoCount(count: counts.videos, days: NowProfile.Counts.videoWindowDays)
            ) {
                router.selectedTab = .videos
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .buttonStyle(.plain)
    }

    /// A count after its symbol; VoiceOver and the pointer's tooltip read
    /// the full label, such as "12 upcoming events".
    private func countButton(
        _ count: Int, systemImage: String, label: LocalizedStringResource, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label {
                Text(count, format: .number)
                    .monospacedDigit()
            } icon: {
                Image(systemName: systemImage)
            }
            .labelStyle(NowCompactLabelStyle())
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .accessibilityLabel(Text(label))
        .help(Text(label))
    }
}
