import KanoNaviCore
import SwiftUI

/// The post archive: one Japan month at a time from the month index, newest
/// first, narrowed by account and paged as the list scrolls. A failed read
/// keeps the posts on screen and says so.
struct PostArchiveScreen: View {
    @State private var model: ArchiveModel<Post>
    /// The board's accounts, from the dashboard's metadata when there is a
    /// snapshot.
    let meta: DashboardMeta?

    init(client: APIClient, meta: DashboardMeta?) {
        _model = State(
            initialValue: ArchiveModel(
                months: PostArchiveSource.months(client: client),
                page: PostArchiveSource.page(client: client), itemID: \.id))
        self.meta = meta
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
                        options: PostAccountFilter.options(
                            accounts: PostAccountFilter.accounts(meta: meta, counts: model.counts),
                            counts: model.counts, allCount: model.allCount),
                        selection: $model.filter, title: .Posts.accountFilter)
                }
            }

            PostArchiveItems(model: model)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(.Posts.archiveTitle)
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
