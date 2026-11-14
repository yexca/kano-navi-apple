import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import WidgetKit

/// The rectangular Lock Screen widget: the live or next entry and its time.
///
/// Its three fixed lines cannot grow, so text stops growing at the largest
/// non-accessibility size, where the time still fits in full.
struct RectangularUpcomingView: View {
    let entry: UpcomingEntry

    var body: some View {
        content
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    @ViewBuilder private var content: some View {
        switch entry.content {
        case .unavailable:
            UnavailableView(isCompact: true)
        case .schedule(let schedule):
            if let item = schedule.next(at: entry.date) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        if item.isLive(at: entry.date) {
                            LiveIndicator()
                                .widgetAccentable()
                        } else {
                            Text(.widgetNext)
                                .fontWeight(.semibold)
                                .widgetAccentable()
                        }
                        Spacer(minLength: 2)
                        FreshnessLabel(schedule: schedule, iconOnly: true)
                    }
                    .font(.caption)
                    EntryTitle(item: item)
                        .font(.headline)
                    RectangularTimeLine(item: item, now: entry.date, today: entry.today)
                        .font(.caption)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(.widgetNothingScheduled)
                    .font(.caption)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
