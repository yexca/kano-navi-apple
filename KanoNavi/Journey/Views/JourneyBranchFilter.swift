import KanoNaviCore
import SwiftUI

/// Kano's identities as cards that filter the Journey: All, then each branch
/// with its portrait, name, the year it starts and its count. Tapping the
/// selected card again shows all.
struct JourneyBranchFilter: View {
    let branches: [JourneyBranch]
    @Binding var selection: String?
    let counts: [String: Int]
    let total: Int
    let countLabel: (Int) -> LocalizedStringResource

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 10) {
                JourneyBranchCard(
                    branch: nil, count: countLabel(total), isSelected: selection == nil, select: selectAll)
                ForEach(branches) { branch in
                    JourneyBranchCard(
                        branch: branch, count: countLabel(counts[branch.id] ?? 0),
                        isSelected: selection == branch.id
                    ) {
                        toggle(branch.id)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(.Journey.identityFilter))
    }

    private func selectAll() {
        selection = nil
    }

    private func toggle(_ id: String) {
        selection = selection == id ? nil : id
    }
}
