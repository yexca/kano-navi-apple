import KanoNaviCore
import SwiftUI

/// What the viewer shows under a Works image: its caption, the credit its
/// contributor asks for, whether the file is the publisher's or a third
/// party's, and where it was taken from.
struct WorksImageCaption: View {
    let image: WorksImage
    /// Shown when the image has no caption: the work's title.
    let fallbackTitle: String

    @ContentLocaleSetting private var contentLocale

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: Self.title(of: image, in: contentLocale) ?? fallbackTitle)
                .font(.headline)

            if let credit = image.credit {
                WorksImageCreditLine(credit: credit)
            }

            if let thirdParty = image.thirdParty {
                Label {
                    Text(thirdParty ? .Works.imageThirdParty : .Works.imagePublisher)
                } icon: {
                    Image(systemName: thirdParty ? "building.2" : "checkmark.seal")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if let provenance = WorksImageProvenance(image) {
                WorksImageSourceLine(provenance: provenance)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The image's caption in the content language, or `nil` without one.
    nonisolated static func title(of image: WorksImage, in locale: ContentLocale) -> String? {
        image.caption?.resolved(for: locale)?.text
    }
}
