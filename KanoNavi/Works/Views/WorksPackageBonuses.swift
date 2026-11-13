import KanoNaviCore
import SwiftUI

/// What an edition's package holds beyond the disc: each bonus in words,
/// then the pictures of them.
struct WorksPackageBonuses: View {
    let bonuses: [LocalizedText]
    let images: [WorksImage]
    let open: (WorksImage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(.Works.inPackage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            ForEach(bonuses.enumerated(), id: \.offset) { _, bonus in
                Label {
                    WorksText(bonus)
                } icon: {
                    Image(systemName: "gift")
                        .foregroundStyle(.secondary)
                }
            }
            if images.isEmpty == false {
                WorksImageStrip(
                    images: images, fallbackTitle: String(localized: .Works.inPackage), open: open)
            }
        }
    }
}
