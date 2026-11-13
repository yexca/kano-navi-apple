import SwiftUI

/// A centred line where a filter leaves nothing to show.
struct JourneyEmptyNote: View {
    let message: LocalizedStringResource

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.horizontal)
    }
}
