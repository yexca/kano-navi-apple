import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import WidgetKit

/// One day of the strip: its weekday letter, its date in a circle that is
/// filled for today, and a dot when it has entries.
struct DayStripCell: View {
    let date: JapanDate
    let isToday: Bool
    let hasEntries: Bool

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
            Circle()
                .frame(width: dotSize, height: dotSize)
                .berryForeground()
                .opacity(hasEntries ? 1 : 0)
        }
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(JSTTimeFormat.day(date, locale: locale)))
    }

    private var isFullColor: Bool { renderingMode == .fullColor }
}
