import KanoNaviCore
import SwiftUI

/// The archive month's posts, each in its own grouped card, or why there are
/// none, and the row that reads the next page.
struct PostArchiveItems: View {
    let model: ArchiveModel<PostArchiveEntry>
    /// The dashboard's account avatars, for a page that leaves them out.
    let accountAvatars: [String: URL?]?
    /// Kano's profile avatar, for Kano's own posts without an account avatar.
    let profileAvatarURL: URL?

    var body: some View {
        if let listing = model.listing {
            if listing.items.isEmpty {
                Section {
                    Text(.Posts.archiveMonthEmpty)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(.Posts.postCount(listing.total))
                }
            }
            ForEach(listing.items, id: \.post.id) { entry in
                Section {
                    PostCardView(
                        card: PostCard(
                            post: entry.post, accountAvatars: entry.accountAvatars ?? accountAvatars,
                            profileAvatarURL: profileAvatarURL))
                } header: {
                    if entry.post.id == listing.items.first?.post.id {
                        Text(.Posts.postCount(listing.total))
                    }
                }
            }
            if listing.hasNext {
                Section {
                    ArchiveMoreRow(
                        itemCount: listing.items.count, isLoading: model.isLoadingMore,
                        failed: model.moreFailure != nil, loadMore: model.loadMore)
                }
            }
        } else if model.isEmpty {
            Section {
                Text(.Posts.archiveEmpty)
                    .foregroundStyle(.secondary)
            }
        } else if model.notice == nil {
            Section {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(.Archive.loading)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
