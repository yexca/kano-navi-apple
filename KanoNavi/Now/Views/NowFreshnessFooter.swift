import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One line on how fresh the data is, such as "Updated 17:01 JST · Some
/// sources had warnings", after an info symbol. It turns orange, with a
/// warning symbol instead, when the last run failed or something was not
/// read for a day. Tapping it opens the full detail in a sheet.
struct NowFreshnessFooter: View {
    let freshness: NowFreshness
    /// When this device last received the dashboard.
    let fetchedAt: Date?
    let now: Date

    @Environment(\.locale) private var locale
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

    private var line: String {
        let updated: String =
            if let syncAt = freshness.syncAt, freshness.syncState != .waiting {
                string(.Now.freshnessUpdated(time(syncAt)))
            } else {
                string(.Now.freshnessHeader)
            }
        guard let summary = summaryText else { return updated }
        return string(.Now.freshnessLine(updated, string(summary)))
    }

    private var summaryText: LocalizedStringResource? {
        switch freshness.summary {
        case .healthy: nil
        case .running: .Now.freshnessRunning
        case .warnings: .Now.freshnessWarnings
        case .notReadForADay: .Now.freshnessNotReadForADaySummary
        case .failed: .Now.freshnessFailed
        }
    }

    /// The run's JST time; a run before today also names its day.
    private func time(_ date: Date) -> String {
        JapanDate.date(from: date) == JapanDate.today(at: now)
            ? JSTTimeFormat.time(date, locale: locale)
            : JSTTimeFormat.dateTime(date, locale: locale)
    }

    private func string(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
