import KanoNaviCore
import SwiftUI

/// A branch's name in a capsule of its tone.
struct JourneyBranchTag: View {
    let branch: JourneyBranch
    let tone: JourneyTone

    @ContentLocaleSetting private var contentLocale

    var body: some View {
        Text(verbatim: branch.label.resolved(for: contentLocale)?.text ?? "")
            .font(.caption.weight(.semibold))
            .foregroundStyle(tone.color)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(tone.color.opacity(0.14), in: .capsule)
    }
}
