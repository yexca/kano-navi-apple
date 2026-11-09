import SwiftUI

/// Stands in for a tab whose screen is not built yet.
struct FeaturePlaceholder: View {
    let title: LocalizedStringResource

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label {
                    Text(.rootPlaceholderTitle)
                } icon: {
                    Image(systemName: "hammer")
                }
            } description: {
                Text(.rootPlaceholderMessage)
            }
            .navigationTitle(title)
        }
    }
}
