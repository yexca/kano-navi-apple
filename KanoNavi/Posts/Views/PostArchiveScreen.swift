import Foundation
import KanoNaviCore
import SwiftUI

/// The post archive: one Japan month at a time from the month index, newest
/// first, narrowed by the account filter menu in the navigation bar and
/// paged as the list scrolls. A failed read keeps the posts on screen and
/// says so.
struct PostArchiveScreen: View {
    @State private var model: ArchiveModel<PostArchiveEntry>
    /// The board's accounts, from the dashboard's metadata when there is a
    /// snapshot.
    let meta: DashboardMeta?
    /// The dashboard's account avatars, for pages that leave theirs out.
    let accountAvatars: [String: URL?]?
    /// Kano's profile avatar, for Kano's own posts without an account avatar.
    let profileAvatarURL: URL?

    init(client: APIClient, meta: DashboardMeta?, accountAvatars: [String: URL?]?, profileAvatarURL: URL?) {
        _model = State(
            initialValue: ArchiveModel(
                months: PostArchiveSource.months(client: client),
                page: PostArchiveSource.page(client: client), itemID: \.post.id))
        self.meta = meta
        self.accountAvatars = accountAvatars
        self.profileAvatarURL = profileAvatarURL
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
                }
            }

            PostArchiveItems(
                model: model, accountAvatars: accountAvatars, profileAvatarURL: profileAvatarURL)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .readableContentWidth()
        .refreshable(action: model.refresh)
        .navigationTitle(.Posts.archiveTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let index = model.index, index.months.isEmpty == false {
                ToolbarItem(placement: .primaryAction) {
                    ArchiveFilterMenu(
                        options: PostAccountFilter.options(
                            accounts: PostAccountFilter.accounts(meta: meta, counts: model.counts),
                            counts: model.counts, allCount: model.allCount),
                        selection: $model.filter, title: .Posts.accountFilter
                    )
                    .accessibilityIdentifier("posts.archive.filter")
                }
            }
        }
        .task(id: model.key) {
            await model.loadIfNeeded()
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
