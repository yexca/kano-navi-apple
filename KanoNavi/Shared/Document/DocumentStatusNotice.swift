import KanoNaviComponents
import SwiftUI

/// The notice a single-document screen shows over content that is not a
/// fresh read: the copy saved on this device with the time it was read, or
/// a failed reload, each with Try Again. The content stays on screen.
///
///     if let notice = model.notice {
///         Section { DocumentStatusNotice(notice: notice, reload: model.reload) }
///     }
///
/// A screen that wants its own wording ("Couldn't update the comments…")
/// uses `StatusNotice` with its own message instead.
struct DocumentStatusNotice: View {
    let notice: DocumentNotice
    /// Reads the document again, usually `DocumentModel.reload`.
    let reload: () async -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        StatusNotice(message: message, isSavedCopy: isSaved, retryTitle: .Document.retry, retry: retry)
    }

    private var isSaved: Bool {
        if case .saved = notice { true } else { false }
    }

    private var message: LocalizedStringResource {
        switch notice {
        case .loadFailed: .Document.loadFailed
        case .updateFailed: .Document.updateFailed
        case .saved(let fetchedAt): .Document.savedCopy(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }

    private func retry() {
        Task { await reload() }
    }
}

#Preview {
    List {
        Section {
            DocumentStatusNotice(notice: .saved(fetchedAt: Date(timeIntervalSince1970: 1_794_000_000))) {}
        }
        Section {
            DocumentStatusNotice(notice: .updateFailed) {}
        }
    }
}
