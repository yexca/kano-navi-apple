import SwiftUI

/// The app's first screen. It holds a placeholder until the board's pages exist.
struct RootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text(.rootPlaceholderTitle)
                } icon: {
                    Image(systemName: "calendar")
                }
            } description: {
                Text(.rootPlaceholderMessage)
            }
            .navigationTitle(.appName)
        }
    }
}

#Preview {
    RootView()
}
