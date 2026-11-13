import KanoNaviCore
import SwiftUI

/// Where a release can be streamed or bought as a download, as a list
/// section; nothing without a listing.
struct WorksStoreSection: View {
    let listings: [WorksStoreListing]

    var body: some View {
        if listings.contains(where: { $0.links.isEmpty == false }) {
            Section {
                WorksStoreRows(listings: listings)
            } header: {
                Text(.Works.stores)
            }
        }
    }
}
