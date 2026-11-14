import KanoNaviCore
import SwiftUI

/// The Posts tab's recent posts for one snapshot, newest first as the
/// dashboard lists them, under the account filter, one row that scrolls
/// sideways pinned in the bar area, and the link to the month archive.
struct PostsList: View {
    let snapshot: Dashboard
    let dashboard: DashboardStore
    let showsArchive: Bool

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

            if showsArchive {
                Section {
                    NavigationLink(value: PostsDestination.archive) {
                        Label {
                            Text(.Posts.pastPosts)
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                    .accessibilityIdentifier("posts.archive")
                }
            }
        }
        .listStyle(.insetGrouped)
        // On the scroll view alone: around the bar, the filter row's own
        // scroll view would take a refresh control's room and hide its chips.
        .refreshable(action: dashboard.refresh)
        .safeAreaBar(edge: .top) {
            if cards.isEmpty == false {
                ArchiveFilterRow(
                    options: PostRecentFilter.options(cards: cards, accounts: accounts), selection: $account,
                    title: .Posts.accountFilter)
            }
        }
        // A firm edge under the chips, so posts never show through them.
        .scrollEdgeEffectStyle(.hard, for: .top)
        // A large title would scroll under the pinned row's firm edge.
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: accounts) {
            // An account the board no longer follows shows every post again.
            if let account, accounts.contains(where: { $0.code == account }) == false {
                self.account = nil
            }
        }
    }
}
