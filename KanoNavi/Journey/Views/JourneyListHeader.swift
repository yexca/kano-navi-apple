import KanoNaviCore
import SwiftUI

/// The top of the timeline and the gallery: the notice of a saved copy or a
/// failed read, and the identity chips.
struct JourneyListHeader: View {
    let branches: [JourneyBranch]
    @Binding var branch: String?
    /// The milestones or images each branch ID has.
    let counts: [String: Int]
    let total: Int
    let countLabel: (Int) -> LocalizedStringResource
    let notice: DocumentNotice?
    let reload: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let notice {
                DocumentStatusNotice(notice: notice, reload: reload)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                    .padding(.horizontal)
            }
            JourneyBranchFilter(
                branches: branches, selection: $branch, counts: counts, total: total, countLabel: countLabel)
        }
        .padding(.top, 8)
    }
}
