import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import WidgetKit

/// One entry filling the small widget.
struct SmallEntryView: View {
    let item: WidgetItem
    let schedule: WidgetSchedule
    let now: Date
    let today: JapanDate

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                if item.isLive(at: now) {
                    LiveIndicator()
                        .widgetAccentable()
                } else {
                    Text(.widgetUpNext)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .widgetAccentable()
                }
                Spacer(minLength: 2)
                FreshnessLabel(schedule: schedule, iconOnly: true)
            }
            .font(.caption)
            .lineLimit(1)

            EntryTitle(item: item, lineLimit: dynamicTypeSize.isAccessibilitySize ? 2 : 3)
                .font(.headline)
                .minimumScaleFactor(0.75)
            EntryMarks(item: item)

            Spacer(minLength: 0)

            SmallTimeBlock(item: item, now: now, today: today)
                .layoutPriority(1)
        }
    }
}
