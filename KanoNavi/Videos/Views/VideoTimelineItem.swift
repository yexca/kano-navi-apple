import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One video in the timeline, as a video app's feed draws it: the cover
/// across the width, then the platform, the title in up to two lines and one
/// line of form, tag and JST date. Tapping it opens the video's page; its
/// context menu opens the other platforms, switches a translated title to the
/// original and copies or shares the link.
struct VideoTimelineItem: View {
    let card: VideoCard

    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsOriginal = false

    var body: some View {
        let resolved = card.title.resolved(for: contentLanguage, interfaceLocale: locale)
        let title = showsOriginal ? resolved.original : resolved.text
        Button(action: open) {
            VStack(alignment: .leading, spacing: 12) {
                VideoCover(card: card)
                HStack(alignment: .top, spacing: 12) {
                    if dynamicTypeSize.isAccessibilitySize == false {
                        VideoPlatformAvatar(destination: card.primaryLink?.destination)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: title)
                            .font(.callout.weight(.semibold))
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        meta(isTranslated: resolved.isTranslation && showsOriginal == false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .contextMenu {
            menu(isTranslation: resolved.isTranslation)
        } preview: {
            VideoCover(card: card)
                .frame(width: 360)
        }
        .accessibilityLabel(Text(verbatim: card.accessibilityLabel(title: title, locale: locale)))
        .accessibilityHint(
            card.primaryLink.map { Text(NowLinkButtons.title(for: $0.destination)) } ?? Text(verbatim: "")
        )
        .accessibilityActions {
            ForEach(card.links.dropFirst()) { link in
                Button(NowLinkButtons.title(for: link.destination)) {
                    openURL(link.url)
                }
            }
            if resolved.isTranslation {
                Button(showsOriginal ? .Now.showTranslation : .Now.showOriginal) {
                    showsOriginal.toggle()
                }
            }
            if let url = card.primaryLink?.url {
                Button(.Videos.copyLink) {
                    Pasteboard.copy(url)
                }
            }
        }
    }

    /// The form, tag and date, after a translate glyph when the title shown
    /// is a translation.
    @ViewBuilder private func meta(isTranslated: Bool) -> some View {
        let line = card.metaLine(locale: locale)
        if line.isEmpty == false || isTranslated {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if isTranslated {
                    Image(systemName: "translate")
                        .imageScale(.small)
                }
                Text(verbatim: line)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func menu(isTranslation: Bool) -> some View {
        ForEach(card.links) { link in
            Button {
                openURL(link.url)
            } label: {
                Label {
                    Text(NowLinkButtons.title(for: link.destination))
                } icon: {
                    NowLinkButtons.icon(for: link.destination)
                }
            }
        }
        if isTranslation {
            Button(showsOriginal ? .Now.showTranslation : .Now.showOriginal, systemImage: "translate") {
                showsOriginal.toggle()
            }
        }
        if let url = card.primaryLink?.url {
            Button(.Videos.copyLink, systemImage: "link") {
                Pasteboard.copy(url)
            }
            ShareLink(item: url) {
                Label(.Videos.share, systemImage: "square.and.arrow.up")
            }
        }
    }

    private func open() {
        if let url = card.primaryLink?.url {
            openURL(url)
        }
    }
}
