import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The ticket at the top of the Now tab. Its cover opens the viewer.
struct NowSpotlightTicket: View {
    let spotlight: NowSpotlight
    let now: Date

    /// The cover while the viewer shows it; `nil` while it is closed.
    @State private var openedCover: NowPicture?

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // At accessibility sizes the cover would push the time and links
            // off the first screen.
            if let url = spotlight.thumbnailURL, dynamicTypeSize.isAccessibilitySize == false {
                Button {
                    openedCover = NowPicture(role: .cover, url: url)
                } label: {
                    NowThumbnail(url: url)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(.Now.spotlightCover))
                .accessibilityAddTraits(.isImage)
                .accessibilityHint(Text(.Now.openImageHint))
            }

            NowFlowLayout(spacing: 8) {
                if spotlight.isLive {
                    LiveIndicator()
                }
                if let kicker {
                    Text(kicker)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                if spotlight.showsMembersChip {
                    MembersChip()
                }
            }

            NowTitle(text: spotlight.title, switchable: true)
                .font(.title3.weight(.bold))

            timing

            if spotlight.links.isEmpty == false {
                NowLinkButtons(links: spotlight.links)
            }
        }
        .padding(.vertical, 8)
        .mediaViewer(item: $openedCover, in: openedCover.map { [$0] } ?? []) { picture in
            MediaImageSource(url: picture.url)
        } label: { picture in
            Text(picture.role.name)
        } caption: { [title = spotlight.title] _ in
            NowTitle(text: title, switchable: false)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// The ticket's heading. A live ticket's badge already says "Live", so
    /// only an unannounced broadcast adds where it is live.
    private var kicker: LocalizedStringResource? {
        switch spotlight.mode {
        case .liveNow: .Now.spotlightLiveOn(String(localized: DisplayCodeLabels.platform(.bilibili)))
        case .next: spotlight.isLive ? nil : .Now.spotlightNext
        case .latest: .Now.spotlightLatest
        }
    }

    @ViewBuilder
    private var timing: some View {
        if let startsAt = spotlight.startsAt {
            let time = Text(verbatim: jstTime(startsAt))
            if spotlight.isLive {
                Text(.Now.startedAt(jstTime(startsAt)))
                    .foregroundStyle(.secondary)
            } else if spotlight.mode == .next, startsAt > now {
                NowCountdown(date: startsAt, now: now)
                time.foregroundStyle(.secondary)
            } else {
                time.foregroundStyle(.secondary)
            }
        } else if let startsOn = spotlight.startsOn {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: JSTTimeFormat.day(startsOn, locale: locale))
                Text(.Now.timeTBA)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// The ticket's start as a JST date and time; an estimate reads "about".
    private func jstTime(_ date: Date) -> String {
        let value = JSTTimeFormat.dateTime(date, locale: locale)
        return spotlight.timePrecision == "approximate" ? String(localized: .Now.approximately(value)) : value
    }
}
