import KanoNaviComponents
import SwiftUI

/// The state of the video timeline when it is not a fresh read: a failed
/// load, with or without older videos on screen, or the copy saved on this
/// device with the time it was read. The videos stay on screen.
struct VideoTimelineStatusNotice: View {
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
        case .loadFailed: .Videos.timelineLoadFailed
        case .updateFailed: .Videos.timelineUpdateFailed
        case .saved(let fetchedAt):
            .Videos.timelineSavedCopy(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }
}
