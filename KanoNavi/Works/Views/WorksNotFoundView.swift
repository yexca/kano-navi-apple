import SwiftUI

/// Shown when the collection has loaded but holds no item of the ID a
/// screen was opened with, such as a link to a release that was renamed.
struct WorksNotFoundView: View {
    let title: LocalizedStringResource
    /// Whether the collection is being read now. The copy on screen may be
    /// older than the link that led here, so the screen waits for the read
    /// before saying the item is missing.
    let isLoading: Bool
    /// Why the collection on screen is not a fresh read, if it is not: the
    /// item may exist in a newer one.
    let notice: DocumentNotice?
    /// Reads the collection again, usually `DocumentModel.reload`.
    let reload: () async -> Void

    var body: some View {
        if isLoading {
            ProgressView {
                Text(.Document.loading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: "questionmark.folder")
                }
            } actions: {
                Button(.Document.retry, action: retry)
            }
            .safeAreaInset(edge: .top) {
                if let notice {
                    DocumentStatusNotice(notice: notice, reload: reload)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func retry() {
        Task { await reload() }
    }
}
