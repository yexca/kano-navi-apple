import KanoNaviCore
import SwiftUI

/// Images as a row of thumbnails that scrolls sideways; each opens the
/// viewer. A file listed twice shows once.
struct WorksImageStrip: View {
    let images: [WorksImage]
    /// Read for an image without a caption.
    let fallbackTitle: String
    let open: (WorksImage) -> Void

    @ContentLocaleSetting private var contentLocale
    @ScaledMetric(relativeTo: .body) private var scaledHeight: CGFloat = 84

    /// Thumbnails grow with the text size, up to a point.
    private var height: CGFloat { min(scaledHeight, 140) }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(WorksGallery(images: images).pictures) { picture in
                    Button {
                        open(picture.image)
                    } label: {
                        MediaImage(
                            picture.source,
                            label: Text(
                                verbatim: WorksImageCaption.title(of: picture.image, in: contentLocale)
                                    ?? fallbackTitle)
                        )
                        .frame(height: height)
                        .clipShape(.rect(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text(.Works.openImageHint))
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
