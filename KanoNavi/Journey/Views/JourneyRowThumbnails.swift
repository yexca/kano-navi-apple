import KanoNaviCore
import SwiftUI

/// The first images of a milestone as small cropped squares, with "+N" on
/// the last when there are more. Decorative in the row; VoiceOver hears the
/// count, and the detail page lists every image.
struct JourneyRowThumbnails: View {
    let media: [JourneyMedia]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let limit = dynamicTypeSize.isAccessibilitySize ? 2 : 3
        let shown = Array(media.prefix(limit))
        let hidden = media.count - shown.count
        HStack(spacing: 6) {
            ForEach(shown) { item in
                Color.clear
                    .frame(width: 64, height: 64)
                    .overlay {
                        MediaImage(
                            decorative: item.imageSource, contentMode: .fill, anchor: item.thumbnailAnchor)
                    }
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay {
                        if hidden > 0, item.id == shown.last?.id {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.5))
                            Text(.Journey.moreImages(hidden))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
            }
        }
        .padding(.top, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(.Journey.imageCount(media.count)))
    }
}
