import SwiftUI

/// The caller's caption at the bottom of the viewer: as tall as its text
/// up to `maxHeight`, and scrolling beyond that, so a long credit at a large
/// text size leaves the picture in view.
struct MediaViewerCaptionBar<Content: View>: View {
    let maxHeight: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        // The frame reserves up to `maxHeight` at the bottom; only the
        // caption itself has a backdrop, so a short one stays short. The
        // backdrop is dark enough for white text over a white picture.
        ViewThatFits(in: .vertical) {
            padded
                .background(Self.backdrop)
            ScrollView {
                padded
            }
            .background(Self.backdrop)
        }
        .frame(maxHeight: maxHeight, alignment: .bottom)
    }

    private static var backdrop: Color { .black.opacity(0.72) }

    private var padded: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 12)
    }
}
