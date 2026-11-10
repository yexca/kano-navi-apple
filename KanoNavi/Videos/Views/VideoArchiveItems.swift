import KanoNaviCore
import SwiftUI

/// The archive month's videos, or why there are none, and the row that
/// reads the next page.
struct VideoArchiveItems: View {
    let model: ArchiveModel<Video>

    var body: some View {
        if let listing = model.listing {
            Section {
                if listing.items.isEmpty {
                    Text(.Videos.archiveMonthEmpty)
                        .foregroundStyle(.secondary)
                }
                ForEach(listing.items, id: \.id) { video in
                    VideoRow(card: VideoCard(video: video))
                }
                if listing.hasNext {
                    ArchiveMoreRow(
                        itemCount: listing.items.count, isLoading: model.isLoadingMore,
                        failed: model.moreFailure != nil, loadMore: model.loadMore)
                }
            } header: {
                Text(.Videos.videoCount(listing.total))
            }
        } else if model.isEmpty {
            Section {
                Text(.Videos.archiveEmpty)
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
