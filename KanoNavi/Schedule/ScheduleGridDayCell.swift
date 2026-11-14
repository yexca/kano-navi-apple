import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One day of a vertically scrolling month: its number, today in a filled
/// circle, and its entries in the tag colors, as dots (Compact), bars
/// (Stacked) or one-line titles (Details), with "+n" past what fits.
/// Tapping it opens the day in the List mode.
struct ScheduleGridDayCell: View {
    let date: JapanDate
    let isToday: Bool
    let entries: [ScheduleDayEntry]
    let style: ScheduleMode
    let contentLanguage: ContentLanguage
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .subheadline) private var circleSize = 28.0
    @ScaledMetric(relativeTo: .subheadline) private var compactHeight = 62.0
    @ScaledMetric(relativeTo: .subheadline) private var tallHeight = 92.0
    @ScaledMetric(relativeTo: .caption2) private var dotSize = 6.0
    @ScaledMetric(relativeTo: .caption2) private var barHeight = 6.0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.day, format: .number)
                    .font(.subheadline.weight(isToday ? .semibold : .regular))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                    .frame(width: circleSize, height: circleSize)
                    .background {
                        if isToday {
                            Circle().fill(.tint)
                        }
                    }
                marks
            }
            .frame(
                maxWidth: .infinity, minHeight: style == .compact ? compactHeight : tallHeight,
                alignment: .top
            )
            .padding(.horizontal, 3)
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(
            entries.isEmpty ? Text(verbatim: "") : Text(.Schedule.dayEntryCount(entries.count)))
    }

    @ViewBuilder
    private var marks: some View {
        let marks = style.marks(forEntryCount: entries.count)
        let shown = entries.prefix(marks.shown)
        switch style {
        case .list, .compact:
            // Fewer dots before "+n" would be cut short in a narrow cell.
            ViewThatFits(in: .horizontal) {
                ForEach((1...style.markCapacity).reversed(), id: \.self) { capacity in
                    dots(capacity: capacity)
                }
            }
        case .stacked:
            VStack(spacing: 3) {
                ForEach(shown) { item in
                    Capsule()
                        .fill(color(of: item))
                        .frame(height: barHeight)
                }
                more(marks.more)
            }
        case .details:
            VStack(alignment: .leading, spacing: 2) {
                ForEach(shown) { item in
                    ScheduleGridEntryTitle(item: item, contentLanguage: contentLanguage)
                }
                more(marks.more)
            }
        }
    }

    private func dots(capacity: Int) -> some View {
        let marks = ScheduleMode.marks(forEntryCount: entries.count, capacity: capacity)
        return HStack(spacing: 2) {
            ForEach(entries.prefix(marks.shown)) { item in
                Circle()
                    .fill(color(of: item))
                    .frame(width: dotSize, height: dotSize)
            }
            more(marks.more)
        }
    }

    @ViewBuilder
    private func more(_ count: Int) -> some View {
        if count > 0 {
            Text(.Schedule.moreEntries(count))
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize()
                .frame(maxWidth: style == .compact ? nil : .infinity, alignment: .leading)
        }
    }

    private func color(of item: ScheduleDayEntry) -> Color {
        ScheduleTag(event: item.event).color
            .opacity(item.event.isFadedInSchedule ? ScheduleTag.fadedOpacity : 1)
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
