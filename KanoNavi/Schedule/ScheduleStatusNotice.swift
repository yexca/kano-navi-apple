import SwiftUI

/// The state of the month on screen when it is not a fresh read: a failed
/// load, with or without older data on screen, or a saved copy.
struct ScheduleStatusNotice: View {
    enum Kind {
        case updateFailed
        case loadFailed
        case stale
    }

    let kind: Kind
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(message)
            } icon: {
                Image(systemName: kind == .stale ? "clock.arrow.circlepath" : "exclamationmark.triangle.fill")
                    .foregroundStyle(kind == .stale ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange))
            }
            .font(.subheadline)
            if kind != .stale {
                Button(.Schedule.retry, systemImage: "arrow.clockwise", action: retry)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderless)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var message: LocalizedStringResource {
        switch kind {
        case .updateFailed: .Schedule.updateFailed
        case .loadFailed: .Schedule.loadFailed
        case .stale: .Schedule.staleNotice
        }
    }
}
