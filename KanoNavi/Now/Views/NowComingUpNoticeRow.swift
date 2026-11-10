import KanoNaviComponents
import SwiftUI

/// Why Coming Up is not a fresh read: a failed load, with or without older
/// entries on screen, or the copy saved on this device with the time it was
/// read. The entries stay on screen.
struct NowComingUpNoticeRow: View {
    let notice: NowComingUpNotice
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
            Button(.Now.retry, systemImage: "arrow.clockwise", action: retry)
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
        case .loadFailed: .Now.comingUpLoadFailed
        case .updateFailed: .Now.comingUpUpdateFailed
        case .saved(let fetchedAt): .Now.comingUpSaved(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        }
    }
}
