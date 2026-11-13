import KanoNaviCore
import SwiftUI

/// The heading of the Works entry: the years the collection spans.
struct WorksSummaryHeader: View {
    let summary: WorksSummary

    var body: some View {
        Text(.Works.summaryYears(String(summary.firstYear), String(summary.lastYear)))
            .font(.title2.bold())
            .monospacedDigit()
            .foregroundStyle(.primary)
            .textCase(nil)
            .accessibilityAddTraits(.isHeader)
    }
}
