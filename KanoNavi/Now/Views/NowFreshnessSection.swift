import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The freshness line: the last collection run and each source's last
/// successful read, marking anything not read for a day.
struct NowFreshnessSection: View {
    let freshness: NowFreshness
    /// When this device last received the dashboard.
    let fetchedAt: Date?

    @Environment(\.locale) private var locale

    var body: some View {
        Section {
            LabeledContent {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(DisplayCodeLabels.syncStatus(freshness.syncStatus))
                        .foregroundStyle(freshness.syncNeedsReview ? .orange : .secondary)
                    value(
                        for: freshness.syncAt, state: freshness.syncState, outOfDate: .Now.freshnessOutOfDate)
                }
            } label: {
                Text(.Now.freshnessLastRun)
            }

            ForEach(freshness.sources) { source in
                LabeledContent {
                    value(for: source.readAt, state: source.state, outOfDate: .Now.freshnessNotReadForADay)
                } label: {
                    Text(Self.name(of: source.name))
                }
            }

            if let fetchedAt {
                LabeledContent {
                    Text(fetchedAt, format: .relative(presentation: .named))
                } label: {
                    Text(.Now.freshnessChecked)
                }
            }
        } header: {
            Text(.Now.freshnessHeader)
        } footer: {
            Text(.Now.freshnessFooter)
        }
    }

    @ViewBuilder
    private func value(
        for date: Date?, state: NowFreshness.State, outOfDate: LocalizedStringResource
    ) -> some View {
        switch state {
        case .waiting:
            Text(.Now.freshnessWaiting)
        case .current:
            if let date {
                Text(verbatim: JSTTimeFormat.dateTime(date, locale: locale))
            }
        case .outOfDate:
            VStack(alignment: .trailing, spacing: 2) {
                if let date {
                    Text(verbatim: JSTTimeFormat.dateTime(date, locale: locale))
                }
                Label {
                    Text(outOfDate)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                .labelStyle(NowCompactLabelStyle())
                .foregroundStyle(.orange)
            }
        }
    }

    static func name(of source: NowFreshness.SourceName) -> LocalizedStringResource {
        switch source {
        case .x: .Now.sourceX
        case .youtube: .Now.sourceYouTube
        case .bilibili: .Now.sourceBilibili
        case .shop: .Now.sourceShop
        }
    }
}
