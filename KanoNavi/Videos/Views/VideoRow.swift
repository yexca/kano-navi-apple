import SwiftUI

/// One video in a list: a small cover beside its chips, title and time, with
/// its links below. At accessibility text sizes the cover sits above.
struct VideoRow: View {
    let card: VideoCard

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if dynamicTypeSize.isAccessibilitySize {
                VideoThumbnail(url: card.thumbnailURL, lengthText: card.lengthText)
                VideoRowDetails(card: card)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    VideoThumbnail(url: card.thumbnailURL, lengthText: card.lengthText)
                        .frame(width: 128)
                    VideoRowDetails(card: card)
                }
            }
            VideoLinkStrip(links: card.links)
        }
        .padding(.vertical, 4)
        // Take the height the content needs; a List row placed at a smaller
        // height would squeeze wrapped text to one truncated line.
        .fixedSize(horizontal: false, vertical: true)
    }
}
