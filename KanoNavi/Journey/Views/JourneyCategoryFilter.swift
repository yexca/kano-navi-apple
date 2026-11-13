import KanoNaviCore
import SwiftUI

/// The gallery's image-type choices with their counts for the chosen
/// identity, in the archives' filter look.
struct JourneyCategoryFilter: View {
    let categories: [JourneyCategoryCount]
    /// The images of the chosen identity in every category.
    let total: Int
    @Binding var selection: String?

    var body: some View {
        ArchiveFilterBar(options: options, selection: $selection, title: .Journey.categoryFilter)
    }

    private var options: [ArchiveFilterOption] {
        [ArchiveFilterOption(code: nil, label: .localized(.Journey.categoryAll), count: total)]
            + categories.map { item in
                ArchiveFilterOption(
                    code: item.id, label: .localized(JourneyLabels.category(item.category)), count: item.count
                )
            }
    }
}
