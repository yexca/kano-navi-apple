import SwiftUI

/// Shown when nothing could be read and nothing is cached.
struct UnavailableView: View {
    /// Whether to keep to one line with a small symbol, for the Lock Screen.
    var isCompact = false

    var body: some View {
        if isCompact {
            Label {
                Text(.widgetUnavailableTitle)
            } icon: {
                Image(systemName: "exclamationmark.icloud")
            }
            .font(.footnote.weight(.semibold))
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            StateMessage(systemImage: "exclamationmark.icloud", message: .widgetUnavailableTitle)
        }
    }
}
