import SwiftUI

/// The freshness detail behind the footer line: the last collection run,
/// each source's last read and when this app last checked.
struct NowFreshnessSheet: View {
    let freshness: NowFreshness
    let fetchedAt: Date?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                NowFreshnessSection(freshness: freshness, fetchedAt: fetchedAt)
            }
            .navigationTitle(.Now.freshnessHeader)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
