import SwiftUI

/// A notice over content that is not a fresh read from the service: a line
/// saying why, and a button to read again. The content stays on screen.
///
/// The timelines and the single-document screens word it through
/// `PostTimelineStatusNotice`, `VideoTimelineStatusNotice` and
/// `DocumentStatusNotice`.
struct StatusNotice: View {
    let message: LocalizedStringResource
    /// `true` when the content is the copy saved on this device (a quiet
    /// clock mark); `false` for a failed read (an orange warning mark).
    let isSavedCopy: Bool
    let retryTitle: LocalizedStringResource
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(message)
            } icon: {
                Image(systemName: isSavedCopy ? "clock.arrow.circlepath" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isSavedCopy ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange))
            }
            .font(.subheadline)
            Button(retryTitle, systemImage: "arrow.clockwise", action: retry)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderless)
        }
        .accessibilityElement(children: .contain)
    }
}
