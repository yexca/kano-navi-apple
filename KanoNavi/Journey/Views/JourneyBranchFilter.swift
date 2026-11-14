import KanoNaviCore
import SwiftUI

/// Kano's identities as one scrolling row of equal-height chips that filter
/// the Journey: All, then each branch with its portrait, name and count.
/// Tapping the selected chip again shows all.
struct JourneyBranchFilter: View {
    let branches: [JourneyBranch]
    @Binding var selection: String?
    let counts: [String: Int]
    let total: Int
    let countLabel: (Int) -> LocalizedStringResource

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    JourneyBranchChip(
                        branch: nil, count: total, countLabel: countLabel(total),
                        isSelected: selection == nil,
                        select: selectAll
                    )
                    .id(Self.allID)
                    ForEach(branches) { branch in
                        let count = counts[branch.id] ?? 0
                        JourneyBranchChip(
                            branch: branch, count: count, countLabel: countLabel(count),
                            isSelected: selection == branch.id
                        ) {
                            toggle(branch.id)
                        }
                        .id(branch.id)
                    }
                }
                // Every chip takes the height of the tallest one.
                .fixedSize(horizontal: false, vertical: true)
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

    /// The All chip's scroll ID, which no branch ID can take.
    private static let allID = "\u{0}all"

    private func selectAll() {
        selection = nil
    }

    private func toggle(_ id: String) {
        selection = selection == id ? nil : id
    }
}
