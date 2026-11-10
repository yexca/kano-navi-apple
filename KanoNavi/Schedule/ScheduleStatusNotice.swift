import KanoNaviComponents
import SwiftUI

/// The state of the month on screen when it is not a fresh read: a failed
/// load, with or without older data on screen, or the copy saved on this
/// device with the time it was read. The grid and entries stay on screen.
struct ScheduleStatusNotice: View {
    let notice: ScheduleNotice
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
            Button(.Schedule.retry, systemImage: "arrow.clockwise", action: retry)
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
        case .updateFailed: .Schedule.updateFailed
        case .loadFailed: .Schedule.loadFailed
        case .saved(let fetchedAt?):
            .Schedule.staleNoticeSaved(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
        case .saved(nil): .Schedule.staleNotice
        }
    }
}
