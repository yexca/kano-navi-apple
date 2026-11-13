import KanoNaviCore
import SwiftUI

/// Holds the Works collection for a release screen pushed from outside the
/// Works screen.
struct WorksReleaseLoader: View {
    private let releaseID: String
    @State private var model: DocumentModel<WorksRequest>

    init(client: APIClient, releaseID: String) {
        self.releaseID = releaseID
        _model = State(initialValue: DocumentModel(client: client, request: WorksRequest()))
    }

    var body: some View {
        WorksReleasePage(model: model, releaseID: releaseID)
    }
}
