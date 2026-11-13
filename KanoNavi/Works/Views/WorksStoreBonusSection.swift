import KanoNaviCore
import SwiftUI

/// The store bonuses of a release as a list section; nothing without any.
struct WorksStoreBonusSection: View {
    let bonuses: [WorksStoreBonus]
    /// The release has editions, and these bonuses come with any of them.
    let isForAnyEdition: Bool
    /// The release's title, read for an uncaptioned image of an unnamed item.
    let releaseTitle: String
    let open: (WorksImage) -> Void

    var body: some View {
        if bonuses.isEmpty == false {
            Section {
                ForEach(bonuses.enumerated(), id: \.offset) { _, bonus in
                    WorksStoreBonusRow(bonus: bonus, fallbackTitle: releaseTitle, open: open)
                }
            } header: {
                Text(.Works.storeBonuses)
            } footer: {
                if isForAnyEdition {
                    Text(.Works.anyEdition)
                }
            }
        }
    }
}
