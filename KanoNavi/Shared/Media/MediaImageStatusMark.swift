import SwiftUI

/// A symbol with a short line of text under it, or the symbol alone in a
/// box too small for the text, such as a thumbnail at a large text size.
struct MediaImageStatusMark: View {
    let symbol: String
    let text: LocalizedStringResource

    var body: some View {
        ViewThatFits {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.title3)
                Text(text)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(6)

            Image(systemName: symbol)
                .font(.body)
                .padding(4)

            Image(systemName: symbol)
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
    }
}
