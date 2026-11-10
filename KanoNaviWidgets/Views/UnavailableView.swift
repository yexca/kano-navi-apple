import SwiftUI

/// Shown when nothing could be read and nothing is cached.
struct UnavailableView: View {
    var showsMessage = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label {
                Text(.widgetUnavailableTitle)
            } icon: {
                Image(systemName: "exclamationmark.icloud")
            }
            .font(.footnote.weight(.semibold))
            .minimumScaleFactor(0.6)
            if showsMessage {
                Text(.widgetUnavailableMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
