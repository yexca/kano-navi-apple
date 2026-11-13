import KanoNaviCore
import SwiftUI

/// A strip of images under a small title, as one row.
struct WorksLabeledStrip: View {
    let title: LocalizedStringResource
    let images: [WorksImage]
    let fallbackTitle: String
    let open: (WorksImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            WorksImageStrip(images: images, fallbackTitle: fallbackTitle, open: open)
        }
    }
}
