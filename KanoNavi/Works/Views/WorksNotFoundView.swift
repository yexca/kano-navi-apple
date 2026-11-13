import SwiftUI

/// Shown when the collection has loaded but holds no item of the ID a
/// screen was opened with, such as a link to a release that was renamed.
struct WorksNotFoundView: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    /// Reads the collection again, usually `DocumentModel.reload`.
    let reload: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: "questionmark.folder")
            }
        } description: {
            Text(message)
        } actions: {
            Button(.Document.retry, action: retry)
        }
    }

    private func retry() {
        Task { await reload() }
    }
}
