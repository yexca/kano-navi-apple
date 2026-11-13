import SwiftUI

/// The decoded image placed in its box, or the placeholder while there is
/// none.
struct MediaImagePicture: View {
    let image: CGImage?
    let mode: MediaImageRequest.Mode
    let anchor: UnitPoint

    var body: some View {
        if let image {
            MediaImageLayout(
                aspectRatio: CGFloat(image.width) / CGFloat(max(image.height, 1)), mode: mode, anchor: anchor
            ) {
                Image(decorative: image, scale: 1)
                    .resizable()
            }
        } else {
            Rectangle()
                .fill(.fill.tertiary)
        }
    }
}
