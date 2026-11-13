import KanoNaviComponents
import SwiftUI

/// The notice the Uploads screen shows when the stored covers and newer
/// videos are not a fresh read. The upload list itself stays on screen.
struct WorksStoredNotice: View {
    let notice: DocumentNotice
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
        case .loadFailed: .Works.storedLoadFailed
        case .updateFailed: .Works.storedUpdateFailed
        case .saved(let fetchedAt): .Works.storedSaved(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }

    private func retry() {
        Task { await reload() }
    }
}
