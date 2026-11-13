import KanoNaviCore
import SwiftUI

/// The personal releases as a shelf of covers by year, narrowed to a format.
struct WorksReleasesScreen: View {
    let model: DocumentModel<WorksRequest>

    @State private var format: String?
    @State private var order = WorksOrder.newestFirst

    var body: some View {
        DocumentView(model: model) { works in
            WorksReleaseShelfView(
                shelf: WorksReleaseShelf(releases: works.personal), format: $format, order: order,
                notice: model.notice, reload: model.reload)
        }
        .navigationTitle(.Works.areaReleases)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorksOrderMenu(order: $order)
            }
        }
    }
}
