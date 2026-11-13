import SwiftUI

/// A picture of an article that is fetched once it scrolls into view.
///
/// The reader lays an article out whole, so without this every picture of
/// a long article would load when it opens. Until the picture is first
/// seen, a placeholder of the same shape holds its place, so nothing moves
/// when the file arrives.
struct LineBlogDeferredPicture: View {
    let source: MediaImageSource
    /// A square, cropped thumbnail instead of the whole picture.
    let isThumbnail: Bool

    @State private var hasBeenSeen = false

    /// The shape `MediaImage` holds for a picture of unknown size.
    private static let unknownAspectRatio: CGFloat = 3 / 2

    var body: some View {
        ZStack {
            if hasBeenSeen == false {
                Rectangle()
                    .fill(.fill.tertiary)
                    .aspectRatio(
                        isThumbnail ? 1 : source.aspectRatio ?? Self.unknownAspectRatio, contentMode: .fit)
            } else if isThumbnail {
                MediaImage(decorative: source, contentMode: .fill)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                MediaImage(decorative: source)
            }
        }
        .onScrollVisibilityChange(threshold: 0.01) { isVisible in
            if isVisible {
                hasBeenSeen = true
            }
        }
    }
}
