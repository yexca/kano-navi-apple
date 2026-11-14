import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import WidgetKit

/// One day of the strip: its weekday letter, its date in a circle that is
/// filled for today, and a dot in its tag color for each of its first three
/// entries (one plain dot outside full color).
struct DayStripCell: View {
    let date: JapanDate
    let isToday: Bool
    /// The tags of the day's entries, in order.
    let tags: [ScheduleTag]

    @Environment(\.locale) private var locale
    @Environment(\.widgetRenderingMode) private var renderingMode
    @ScaledMetric(relativeTo: .footnote) private var circleSize = 26.0
    @ScaledMetric(relativeTo: .footnote) private var dotSize = 4.0

    var body: some View {
        VStack(spacing: 2) {
            Text(WidgetFormat.narrowWeekday(date, locale: locale))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(date.day, format: .number)
                .font(.footnote.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(isToday && isFullColor ? Color.onBerry : Color.primary)
                .frame(width: circleSize, height: circleSize)
                .background {
                    if isToday {
                        Circle()
                            .fill(isFullColor ? Color.berry : Color.primary.opacity(0.25))
                    }
                }
            HStack(spacing: 2) {
                ForEach(dotTags.enumerated(), id: \.offset) { _, tag in
                    Circle()
                        .fill(isFullColor ? tag.color : Color.primary)
                        .frame(width: dotSize, height: dotSize)
                        .widgetAccentable()
                }
            }
            .frame(height: dotSize)
        }
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(JSTTimeFormat.day(date, locale: locale)))
    }

    private var isFullColor: Bool { renderingMode == .fullColor }

    /// A dot per entry, at most three, in full color; one plain dot for a
    /// day with entries otherwise.
    private var dotTags: [ScheduleTag] {
        isFullColor ? Array(tags.prefix(3)) : Array(tags.prefix(1))
    }
}
