import KanoNaviCore
import SwiftUI

/// The works Kano took part in, by year.
struct WorksParticipationScreen: View {
    let model: DocumentModel<WorksRequest>

    @State private var order = WorksOrder.newestFirst

    var body: some View {
        DocumentView(model: model) { works in
            WorksParticipationList(
                groups: WorksYearGroup.groups(of: works.participation, order: order, date: \.date),
                notice: model.notice, reload: model.reload)
        }
        .navigationTitle(.Works.areaParticipation)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorksOrderMenu(order: $order)
            }
        }
    }
}
