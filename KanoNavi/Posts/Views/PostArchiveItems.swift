import KanoNaviCore
import SwiftUI

/// The archive month's posts, or why there are none, and the row that reads
/// the next page.
struct PostArchiveItems: View {
    let model: ArchiveModel<Post>

    var body: some View {
        if let listing = model.listing {
            Section {
                if listing.items.isEmpty {
                    Text(.Posts.archiveMonthEmpty)
                        .foregroundStyle(.secondary)
                }
                ForEach(listing.items, id: \.id) { post in
                    PostCardView(card: PostCard(post: post))
                }
                if listing.hasNext {
                    ArchiveMoreRow(
                        itemCount: listing.items.count, isLoading: model.isLoadingMore,
                        failed: model.moreFailure != nil, loadMore: model.loadMore)
                }
            } header: {
                Text(.Posts.postCount(listing.total))
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
