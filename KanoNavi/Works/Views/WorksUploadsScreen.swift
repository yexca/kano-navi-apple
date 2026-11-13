import KanoNaviCore
import SwiftUI

/// The uploads: the collection's list joined with the covers and videos
/// the service stores, and the videos newer than the collection above it.
///
/// Two reads feed it. The list is the screen's document; the stored data
/// only adds to it, so the list shows on its own while that read runs or
/// after it fails.
struct WorksUploadsScreen: View {
    @State private var list: DocumentModel<WorksUploadListRequest>
    @State private var stored: DocumentModel<WorksUploadsRequest>

    @State private var kind: String?
    @State private var order = WorksOrder.newestFirst
    @State private var query = ""

    init(client: APIClient) {
        _list = State(initialValue: DocumentModel(client: client, request: WorksUploadListRequest()))
        _stored = State(initialValue: DocumentModel(client: client, request: WorksUploadsRequest()))
    }

    var body: some View {
        DocumentView(model: list) { uploads in
            WorksUploadsList(
                catalog: WorksUploadCatalog(list: uploads, stored: stored.value).searching(query),
                recent: query.isEmpty ? WorksRecentUploads(stored.value) : nil,
                updatedAt: uploads.updatedAt, kind: $kind, order: order, listNotice: list.notice,
                storedNotice: stored.notice, reload: reload)
        }
        .task {
            await stored.load()
        }
        // A search starts from every kind: the kind chosen before may have
        // no match, and its choice is then not among the ones shown.
        .onChange(of: query) {
            kind = nil
        }
        .searchable(
            text: $query, placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(.Works.uploadsSearchPrompt)
        )
        .navigationTitle(.Works.areaUploads)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorksOrderMenu(order: $order)
            }
        }
    }

    /// Reads both documents again, at the same time.
    private func reload() async {
        async let listRead: Void = list.reload()
        async let storedRead: Void = stored.reload()
        _ = await (listRead, storedRead)
    }
}
