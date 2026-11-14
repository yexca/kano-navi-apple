import KanoNaviCore
import SwiftUI

/// The Posts tab's recent posts for one snapshot, newest first as the
/// dashboard lists them, narrowed by the account filter menu at the leading
/// end of the navigation bar.
struct PostsList: View {
    let snapshot: Dashboard
    let dashboard: DashboardStore

    /// The chosen account's filter code, or `nil` for every post.
    @State private var account: String?

    var body: some View {
        let cards = snapshot.posts.map(PostCard.init(post:))
        let accounts = PostRecentFilter.accounts(meta: snapshot.meta)
        let shown = PostRecentFilter.cards(cards, code: account)
        List {
            DashboardNoticeSection(dashboard: dashboard)

            Section {
                if cards.isEmpty {
                    Text(.Posts.recentEmpty(snapshot.meta.postWindowDays))
                        .foregroundStyle(.secondary)
                } else if shown.isEmpty {
                    Text(.Posts.recentAccountEmpty)
                        .foregroundStyle(.secondary)
                }
                ForEach(shown) { card in
                    PostCardView(card: card)
                }
            } header: {
                Text(.Posts.recentHeader)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable(action: dashboard.refresh)
        .toolbar {
            if cards.isEmpty == false {
                ToolbarItem(placement: .topBarLeading) {
                    ArchiveFilterMenu(
                        options: PostRecentFilter.options(cards: cards, accounts: accounts),
                        selection: $account, title: .Posts.accountFilter
                    )
                    .accessibilityIdentifier("posts.filter")
                }
            }
        }
        .onChange(of: accounts) {
            // An account the board no longer follows shows every post again.
            if let account, accounts.contains(where: { $0.code == account }) == false {
                self.account = nil
            }
        }
    }
}
