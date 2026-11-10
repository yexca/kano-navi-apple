import KanoNaviComponents
import SwiftUI

/// The state of an archive month on screen when it is not a fresh read: a
/// failed load, with or without older items on screen, or the copy saved on
/// this device with the time it was read. The items stay on screen.
struct ArchiveStatusNotice: View {
    let notice: ArchiveNotice
    let retry: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(message)
            } icon: {
                Image(systemName: isSaved ? "clock.arrow.circlepath" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isSaved ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange))
            }
            .font(.subheadline)
            Button(.Archive.retry, systemImage: "arrow.clockwise", action: retry)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderless)
        }
        .accessibilityElement(children: .contain)
    }

    private var isSaved: Bool {
        if case .saved = notice { true } else { false }
    }

    private var message: LocalizedStringResource {
        switch notice {
        case .loadFailed: .Archive.loadFailed
        case .updateFailed: .Archive.updateFailed
        case .saved(let fetchedAt): .Archive.savedCopy(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }
}
