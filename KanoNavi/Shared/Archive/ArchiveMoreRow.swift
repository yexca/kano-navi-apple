import SwiftUI

/// The end of a loaded archive month: reads the next page when it appears,
/// and offers to try again when that read failed.
struct ArchiveMoreRow: View {
    /// The items listed so far; the next page is read again once more items
    /// are listed and the row is still on screen.
    let itemCount: Int
    let isLoading: Bool
    let failed: Bool
    let loadMore: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if failed {
                Label {
                    Text(.Archive.loadMoreFailed)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                .font(.subheadline)
                Button(.Archive.retry, systemImage: "arrow.clockwise", action: retry)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderless)
                    .disabled(isLoading)
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(.Archive.loadingMore)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task(id: itemCount * 2 + (failed ? 1 : 0)) {
            if failed == false {
                await loadMore()
            }
        }
    }

    private func retry() {
        Task { await loadMore() }
    }
}
