import SwiftUI

/// One line on the data's status, such as "Some sources had warnings", or
/// the freshness header when all is well, after an info symbol; the update
/// time is the Now screen's navigation subtitle. It turns orange, with a
/// warning symbol instead, when the last run failed or something was not
/// read for a day. Tapping it opens the full detail in a sheet.
struct NowFreshnessFooter: View {
    let freshness: NowFreshness
    /// When this device last received the dashboard.
    let fetchedAt: Date?

    @State private var showsDetail = false

    var body: some View {
        Button {
            showsDetail = true
        } label: {
            // The symbol leads, so it stays beside the first line when the
            // text wraps at large sizes.
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: freshness.needsAttention ? "exclamationmark.triangle.fill" : "info.circle")
                    .accessibilityHidden(true)
                Text(line)
            }
            .font(.footnote)
            .foregroundStyle(freshness.needsAttention ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(.Now.freshnessDetailHint))
        .sheet(isPresented: $showsDetail) {
            NowFreshnessSheet(freshness: freshness, fetchedAt: fetchedAt)
        }
    }

    private var line: LocalizedStringResource {
        switch freshness.summary {
        case .healthy: .Now.freshnessHeader
        case .running: .Now.freshnessRunning
        case .warnings: .Now.freshnessWarnings
        case .notReadForADay: .Now.freshnessNotReadForADaySummary
        case .failed: .Now.freshnessFailed
        }
    }
}
