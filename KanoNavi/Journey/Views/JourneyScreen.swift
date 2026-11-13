import KanoNaviCore
import SwiftUI

/// Loads the Journey document and shows it, keeping the last good copy on
/// screen when a read fails.
struct JourneyScreen: View {
    @State private var model: DocumentModel<JourneyRequest>

    init(client: APIClient) {
        _model = State(initialValue: DocumentModel(client: client, request: JourneyRequest()))
    }

    var body: some View {
        DocumentView(model: model) { journey in
            JourneyContent(journey: journey, notice: model.notice, reload: model.reload)
        }
        .navigationTitle(.More.moreJourney)
        .navigationBarTitleDisplayMode(.inline)
    }
}
