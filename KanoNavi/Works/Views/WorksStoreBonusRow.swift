import KanoNaviCore
import SwiftUI

/// A store's bonus for buying a release or edition: the store, the item
/// and its pictures.
struct WorksStoreBonusRow: View {
    let bonus: WorksStoreBonus
    let open: (WorksImage) -> Void

    @ContentLocaleSetting private var contentLocale

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                WorksText(bonus.store)
            } icon: {
                Image(systemName: "storefront")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            WorksText(bonus.item)
            if bonus.images.isEmpty == false {
                WorksImageStrip(
                    images: bonus.images, fallbackTitle: bonus.item.resolved(for: contentLocale)?.text ?? "",
                    open: open
                )
                .padding(.top, 2)
            }
        }
    }
}
