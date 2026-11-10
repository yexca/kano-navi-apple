import KanoNaviComponents
import SwiftUI

/// Marks data shown from the snapshot saved on this device before a refresh
/// has succeeded, with the time it was received.
struct NowSavedCopyNotice: View {
    let isUpdating: Bool
    /// When the saved snapshot was received from the service.
    let fetchedAt: Date?

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                Text(message)
            } icon: {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.secondary)
            }
            if isUpdating {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text(.Now.savedCopyUpdating)
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }

    private var message: LocalizedStringResource {
        guard let fetchedAt else { return .Now.savedCopy }
        return .Now.savedCopyFrom(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
    }
}
