import SwiftUI

/// The Works screen the More tab opens. See `docs/design.md`.
struct WorksView: View {
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
        .navigationTitle(.More.moreWorks)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorksView()
    }
}
