import SwiftUI

/// What a single-document screen shows while it has no document at all:
/// loading, or the reason the first load failed with Try Again. `extra`
/// adds an action under it, such as a link to the web page.
///
/// `DocumentView` shows it for you; use it directly only for a custom
/// layout.
struct DocumentUnavailableView<Extra: View>: View {
    /// Why the load failed, or `nil` while it runs.
    let reason: DocumentFailureReason?
    /// Reads the document again, usually `DocumentModel.reload`.
    let reload: () async -> Void
    @ViewBuilder var extra: Extra

    var body: some View {
        if let reason {
            ContentUnavailableView {
                Label {
                    Text(reason == .updateNeeded ? .Document.updateNeededTitle : .Document.unavailableTitle)
                } icon: {
                    Image(systemName: symbol(for: reason))
                }
            } description: {
                Text(reason.message)
            } actions: {
                if reason != .updateNeeded {
                    Button(.Document.retry, action: retry)
                        .buttonStyle(.borderedProminent)
                }
                extra
            }
        } else {
            ProgressView {
                Text(.Document.loading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func symbol(for reason: DocumentFailureReason) -> String {
        switch reason {
        case .offline: "wifi.slash"
        case .updateNeeded: "arrow.down.app"
        case .serverError, .unreadable: "exclamationmark.triangle"
        }
    }

    private func retry() {
        Task { await reload() }
    }
}

extension DocumentUnavailableView where Extra == EmptyView {
    init(reason: DocumentFailureReason?, reload: @escaping () async -> Void) {
        self.init(reason: reason, reload: reload) {}
    }
}

#Preview("Failed") {
    DocumentUnavailableView(reason: .offline) {}
}

#Preview("Loading") {
    DocumentUnavailableView(reason: nil) {}
}
