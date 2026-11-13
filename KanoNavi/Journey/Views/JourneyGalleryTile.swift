import KanoNaviCore
import SwiftUI

/// One gallery thumbnail: the image cropped to a square around its `focus`,
/// marked when its release was cancelled. VoiceOver reads its title and
/// what it shows.
struct JourneyGalleryTile: View {
    let media: JourneyMedia
    let open: () -> Void

    @ContentLocaleSetting private var contentLocale
    @Environment(\.locale) private var locale

    var body: some View {
        Button(action: open) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    MediaImage(
                        decorative: media.imageSource, contentMode: .fill, anchor: media.thumbnailAnchor)
                }
                .clipShape(.rect(cornerRadius: 6))
                .overlay(alignment: .bottomLeading) {
                    if media.cancelled == true {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .orange)
                            .font(.subheadline)
                            .padding(4)
                    }
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(Text(.Journey.openImageHint))
        .accessibilityIdentifier("journey.tile." + media.id)
    }

    /// The title, what the image shows and, for a cancelled release, that
    /// it was cancelled.
    private var accessibilityLabel: Text {
        var parts = [media.title(in: contentLocale), localized(JourneyLabels.category(media.category))]
        if media.cancelled == true {
            parts.append(localized(.Journey.cancelledMark))
        }
        return Text(verbatim: parts.filter { $0.isEmpty == false }.joined(separator: ", "))
    }

    private func localized(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
