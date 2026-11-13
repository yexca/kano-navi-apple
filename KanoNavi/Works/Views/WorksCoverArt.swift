import KanoNaviCore
import SwiftUI

/// A release's or work's cover in a square: the whole artwork on a quiet
/// ground, or a disc mark when the record has no cover. Decorative; the
/// card or row it sits in names the work.
struct WorksCoverArt: View {
    let image: WorksImage?
    var cornerRadius: CGFloat = 10

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image {
                    MediaImage(
                        decorative: MediaImageSource(url: image.url, width: image.width, height: image.height)
                    )
                } else {
                    Image(systemName: "opticaldisc")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.tertiary)
                        .padding(.all, 28)
                        .frame(maxWidth: 140, maxHeight: 140)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .accessibilityHidden(true)
    }
}
