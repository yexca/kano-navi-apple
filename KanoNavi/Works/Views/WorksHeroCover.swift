import KanoNaviCore
import SwiftUI

/// The large cover at the top of a release or work; tapping it opens the
/// viewer. Without a cover it is a disc mark that does nothing.
struct WorksHeroCover: View {
    let image: WorksImage?
    /// The work's title, read when the image has no caption.
    let title: String
    let open: (WorksImage) -> Void

    @ContentLocaleSetting private var contentLocale

    /// Wide enough to read the artwork, small enough to leave the title in
    /// view on a small phone.
    private static let maxWidth: CGFloat = 320

    var body: some View {
        ZStack {
            if let image {
                Button {
                    open(image)
                } label: {
                    MediaImage(
                        MediaImageSource(url: image.url, width: image.width, height: image.height),
                        label: Text(verbatim: WorksImageCaption.title(of: image, in: contentLocale) ?? title)
                    )
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text(.Works.openImageHint))
            } else {
                WorksCoverArt(image: nil, cornerRadius: 12)
                    .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: Self.maxWidth)
        .frame(maxWidth: .infinity)
    }
}
