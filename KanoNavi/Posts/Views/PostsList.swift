import KanoNaviCore
import SwiftUI

/// The Posts tab's recent posts for one snapshot, newest first as the
/// dashboard lists them, each in its own grouped card, narrowed by the
/// account filter menu at the leading end of the navigation bar.
struct PostsList: View {
    let snapshot: Dashboard
    let dashboard: DashboardStore

    /// The chosen account's filter code, or `nil` for every post.
    @State private var account: String?

    var body: some View {
        let cards = snapshot.posts.map {
            PostCard(
                post: $0, accountAvatars: snapshot.accountAvatars,
                profileAvatarURL: snapshot.profile.avatarURL)
        }
        let accounts = PostRecentFilter.accounts(meta: snapshot.meta)
        let shown = PostRecentFilter.cards(cards, code: account)
        List {
            DashboardNoticeSection(dashboard: dashboard)

            if cards.isEmpty || shown.isEmpty {
                Section {
                    if cards.isEmpty {
                        Text(.Posts.recentEmpty(snapshot.meta.postWindowDays))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(.Posts.recentAccountEmpty)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(.Posts.recentHeader)
                }
            }
            ForEach(shown) { card in
                Section {
                    PostCardView(card: card)
                } header: {
                    if card.id == shown.first?.id {
                        Text(.Posts.recentHeader)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .readableContentWidth()
        // The images at the top are drawn on the first frame when the disk
        // cache has them.
        .environment(\.mediaImageDecodesCachedFilesAtOnce, true)
        .animation(.default, value: dashboard.phase)
        .overlay(alignment: .bottom) {
            NowSavedCopyNotice(dashboard: dashboard)
        }
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
