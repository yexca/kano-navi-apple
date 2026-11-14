import KanoNaviCore
import SwiftUI

/// One participation work out of the Works collection: its detail, or that
/// the collection has no such work.
struct WorksParticipationPage: View {
    let model: DocumentModel<WorksRequest>
    let workID: String

    var body: some View {
        DocumentView(model: model) { works in
            if let work = works.participation.first(where: { $0.id == workID }) {
                WorksParticipationDetail(work: work, notice: model.notice, reload: model.reload)
            } else {
                WorksNotFoundView(
                    title: .Works.workNotFoundTitle, isLoading: model.phase == .loading, notice: model.notice,
                    reload: model.reload)
            }
        }
        .inlineNavigationTitle()
    }
}
