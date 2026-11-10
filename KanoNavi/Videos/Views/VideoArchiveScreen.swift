import KanoNaviCore
import SwiftUI

/// The video archive: one Japan month at a time from the month index, newest
/// first, narrowed by category and paged as the list scrolls. A failed read
/// keeps the videos on screen and says so.
struct VideoArchiveScreen: View {
    @State private var model: ArchiveModel<Video>

    init(client: APIClient) {
        _model = State(
            initialValue: ArchiveModel(
                months: VideoArchiveSource.months(client: client),
                page: VideoArchiveSource.page(client: client), itemID: \.id))
    }

    var body: some View {
        List {
            if let notice = model.notice {
                Section {
                    ArchiveStatusNotice(notice: notice, retry: retry)
                }
            }

            if let index = model.index, index.months.isEmpty == false {
                Section {
                    ArchiveMonthPicker(index: index, selection: $model.selectedMonth)
                    ArchiveFilterBar(
                        options: VideoCategory.options(counts: model.counts, allCount: model.allCount),
                        selection: $model.filter, title: .Videos.categoryFilter)
                }
            }

            VideoArchiveItems(model: model)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(.Videos.archiveTitle)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable(action: model.refresh)
        .task(id: model.key) {
            await model.loadIfNeeded()
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
