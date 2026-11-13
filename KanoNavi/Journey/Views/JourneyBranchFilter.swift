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
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 10) {
                    JourneyBranchCard(
                        branch: nil, count: countLabel(total), isSelected: selection == nil, select: selectAll
                    )
                    .id(Self.allID)
                    ForEach(branches) { branch in
                        JourneyBranchCard(
                            branch: branch, count: countLabel(counts[branch.id] ?? 0),
                            isSelected: selection == branch.id
                        ) {
                            toggle(branch.id)
                        }
                        .id(branch.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                proxy.scrollTo(selection ?? Self.allID, anchor: .center)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(.Journey.identityFilter))
    }

    /// The All card's scroll ID, which no branch ID can take.
    private static let allID = "\u{0}all"

    private func selectAll() {
        selection = nil
    }

    private func toggle(_ id: String) {
        selection = selection == id ? nil : id
    }
}
