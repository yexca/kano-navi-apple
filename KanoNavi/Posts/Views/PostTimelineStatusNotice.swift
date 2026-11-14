import KanoNaviComponents
import SwiftUI

/// The state of the post timeline when it is not a fresh read: a failed
/// load, with or without older posts on screen, or the copy saved on this
/// device with the time it was read. The posts stay on screen.
struct PostTimelineStatusNotice: View {
    let notice: ArchiveNotice
    let retry: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        StatusNotice(message: message, isSavedCopy: isSaved, retryTitle: .Archive.retry, retry: retry)
    }

    private var isSaved: Bool {
        if case .saved = notice { true } else { false }
    }

    private var message: LocalizedStringResource {
        switch notice {
        case .loadFailed: .Posts.timelineLoadFailed
        case .updateFailed: .Posts.timelineUpdateFailed
        case .saved(let fetchedAt):
            .Posts.timelineSavedCopy(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }
}
