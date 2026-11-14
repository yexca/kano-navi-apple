import SwiftUI

/// One image of a post, cropped to fill a tile of the given shape.
struct PostImageTile: View {
    let image: PostImage
    let aspectRatio: CGFloat
    /// Images not drawn after this one, shown as `+N` over it.
    let hiddenCount: Int

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                MediaImage(decorative: MediaImageSource(url: image.url), contentMode: .fill)
            }
            .overlay {
                if hiddenCount > 0 {
                    Text(.Posts.moreImages(hiddenCount))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.45))
                }
            }
            .clipShape(.rect(cornerRadius: 8))
            // Keep the height the width gives; a List row placing the row
            // at its measured height must not squeeze the image narrower.
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isImage)
    }

    private var label: Text {
        if let alt = image.alt, alt.isEmpty == false {
            Text(verbatim: alt)
        } else {
            Text(.Posts.image)
        }
    }
}
