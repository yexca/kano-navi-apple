import SwiftUI

/// The Journey screen the More tab opens. See `docs/design.md`.
struct JourneyView: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(.rootPlaceholderTitle)
            } icon: {
                Image(systemName: "hammer")
            }
        } description: {
            Text(.rootPlaceholderMessage)
        }
        .navigationTitle(.More.moreJourney)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        JourneyView()
    }
}
