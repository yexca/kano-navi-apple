import KanoNaviCore
import SwiftUI

/// One release out of a Works collection that is loading or loaded: its
/// detail, or that the collection has no such release.
struct WorksReleasePage: View {
    let model: DocumentModel<WorksRequest>
    let releaseID: String

    var body: some View {
        DocumentView(model: model) { works in
            if let release = works.personal.first(where: { $0.id == releaseID }) {
                WorksReleaseDetail(release: release, notice: model.notice, reload: model.reload)
            } else {
                WorksNotFoundView(
                    title: .Works.releaseNotFoundTitle, message: .Works.releaseNotFoundMessage,
                    isLoading: model.phase == .loading, notice: model.notice, reload: model.reload)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
