import SwiftUI

/// What a `MediaImage` draws over its placeholder when there is no image to
/// show: that the file is unavailable, or a button to try a failed fetch
/// again.
struct MediaImageStatus: View {
    let phase: MediaImagePhase
    let retry: () -> Void

    var body: some View {
        switch phase {
        case .unavailable:
            MediaImageStatusMark(symbol: "photo.badge.exclamationmark", text: .Media.imageUnavailable)
                // The picture's accessibility value already says it.
                .accessibilityHidden(true)
        case .failed:
            Button(action: retry) {
                MediaImageStatusMark(symbol: "arrow.clockwise", text: .Media.imageRetry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(.Media.imageRetry))
        case .loading, .loaded:
            EmptyView()
        }
    }
}
