import KanoNaviCore
import SwiftUI

/// The Works entry: reads the collection once and hands it to the screens
/// it opens, so moving between them reads nothing again.
struct WorksHomeScreen: View {
    private let client: APIClient
    @State private var model: DocumentModel<WorksRequest>

    init(client: APIClient) {
        self.client = client
        _model = State(initialValue: DocumentModel(client: client, request: WorksRequest()))
    }

    var body: some View {
        DocumentView(model: model) { works in
            WorksHomeList(works: works, notice: model.notice, reload: model.reload)
        }
        .navigationDestination(for: WorksDestination.self) { destination in
            switch destination {
            case .releases: WorksReleasesScreen(model: model)
            case .release(let id): WorksReleasePage(model: model, releaseID: id)
            case .participation: WorksParticipationScreen(model: model)
            case .participationWork(let id): WorksParticipationPage(model: model, workID: id)
            case .uploads: WorksUploadsScreen(client: client)
            }
        }
    }
}
