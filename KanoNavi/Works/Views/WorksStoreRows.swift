import KanoNaviCore
import SwiftUI

/// Store listings as rows: each listing's item, when it is not the main
/// one, over its store pages.
struct WorksStoreRows: View {
    let listings: [WorksStoreListing]

    var body: some View {
        ForEach(listings.enumerated(), id: \.offset) { _, listing in
            if let item = listing.item, item.isEmpty == false {
                WorksText(item)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
            }
            ForEach(listing.links.enumerated(), id: \.offset) { _, link in
                WorksStoreLinkRow(link: link)
            }
        }
    }
}
