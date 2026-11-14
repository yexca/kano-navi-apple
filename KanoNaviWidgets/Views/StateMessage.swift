import SwiftUI

/// A widget's whole content when it has no entry to show: a Berry symbol and
/// one short line.
struct StateMessage: View {
    let systemImage: String
    let message: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .berryForeground()
                .accessibilityHidden(true)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
