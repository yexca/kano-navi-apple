import KanoNaviCore
import SwiftUI

/// The Works entry: reads the collection, the upload list and the stored
/// uploads, and hands them to the screens it opens, so moving between them
/// reads nothing again.
///
/// The collection is the entry's document. The two upload reads only add
/// Latest Uploads and the uploads of On This Day, so the entry shows
/// without them while they run or after they fail; Uploads says why when
/// it opens.
struct WorksHomeScreen: View {
    @State private var model: DocumentModel<WorksRequest>
    @State private var uploadList: DocumentModel<WorksUploadListRequest>
    @State private var storedUploads: DocumentModel<WorksUploadsRequest>

    init(client: APIClient) {
        _model = State(initialValue: DocumentModel(client: client, request: WorksRequest()))
        _uploadList = State(initialValue: DocumentModel(client: client, request: WorksUploadListRequest()))
        _storedUploads = State(initialValue: DocumentModel(client: client, request: WorksUploadsRequest()))
    }

    var body: some View {
        DocumentView(model: model) { works in
            WorksHomeList(
                works: works, uploadList: uploadList.value, storedUploads: storedUploads.value,
                notice: model.notice, reload: reload)
        }
        .task {
            async let listRead: Void = uploadList.load()
            async let storedRead: Void = storedUploads.load()
            _ = await (listRead, storedRead)
        }
        .navigationDestination(for: WorksDestination.self) { destination in
            switch destination {
            case .releases: WorksReleasesScreen(model: model)
            case .release(let id): WorksReleasePage(model: model, releaseID: id)
            case .participation: WorksParticipationScreen(model: model)
            case .participationWork(let id): WorksParticipationPage(model: model, workID: id)
            case .uploads: WorksUploadsScreen(list: uploadList, stored: storedUploads)
            }
        }
    }

    /// Reads all three documents again, at the same time.
    private func reload() async {
        async let worksRead: Void = model.reload()
        async let listRead: Void = uploadList.reload()
        async let storedRead: Void = storedUploads.reload()
        _ = await (worksRead, listRead, storedRead)
    }
}
