import SwiftUI
import WidgetKit

/// The medium and large widgets' heading, noting that times are Japan time,
/// or that the data is cached.
struct ListHeader: View {
    let schedule: WidgetSchedule
    /// Whether to keep to one short line: the rows then label their own
    /// times as JST, and a cached result shows only its icon.
    var isCompact = false

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                title
                Spacer(minLength: 4)
                note
            }
            VStack(alignment: .leading, spacing: 0) {
                title
                note
            }
        }
        .lineLimit(1)
    }

    private var title: some View {
        Text(.widgetUpcomingName)
            .font(.caption.weight(.bold))
            .widgetAccentable()
    }

    @ViewBuilder private var note: some View {
        if schedule.isStale {
            FreshnessLabel(schedule: schedule, iconOnly: isCompact)
        } else if isCompact == false {
            Text(.widgetTimesInJST)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
