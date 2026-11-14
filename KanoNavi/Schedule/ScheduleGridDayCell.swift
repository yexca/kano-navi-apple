import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One day of a vertically scrolling month: a hairline above, its number
/// (gray on weekends, white in a tint circle for today), and its entries in
/// the tag colors, as dots (Compact), bars (Stacked) or one-line titles
/// (Details), with "+n" past what fits. Tapping it opens the day in the List
/// mode. Takes plain values and compares equal without its action.
struct ScheduleGridDayCell: View, Equatable {
    let date: JapanDate
    let isToday: Bool
    let marks: [ScheduleDayMark]
    let style: ScheduleMode
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .subheadline) private var circleSize = 28.0
    @ScaledMetric(relativeTo: .subheadline) private var compactHeight = 62.0
    @ScaledMetric(relativeTo: .subheadline) private var tallHeight = 92.0
    @ScaledMetric(relativeTo: .caption2) private var barHeight = 6.0

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date && lhs.isToday == rhs.isToday && lhs.marks == rhs.marks
            && lhs.style == rhs.style
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.day, format: .number)
                    .font(.subheadline.weight(isToday ? .semibold : .regular))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(numberStyle)
                    .frame(width: circleSize, height: circleSize)
                    .background {
                        if isToday {
                            Circle().fill(.tint)
                        }
                    }
                content
            }
            .frame(
                maxWidth: .infinity, minHeight: style == .compact ? compactHeight : tallHeight,
                alignment: .top
            )
            .padding(.horizontal, 3)
            .padding(.vertical, 4)
            .overlay(alignment: .top) {
                ScheduleHairline()
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(marks.isEmpty ? Text(verbatim: "") : Text(.Schedule.dayEntryCount(marks.count)))
    }

    private var numberStyle: AnyShapeStyle {
        if isToday {
            AnyShapeStyle(.white)
        } else if date.isWeekend {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.primary)
        }
    }

    @ViewBuilder
    private var content: some View {
        let shape = style.marks(forEntryCount: marks.count)
        let shown = marks.prefix(shape.shown)
        switch style {
        case .list, .compact:
            ScheduleDayDots(marks: marks, capacity: style.markCapacity)
        case .stacked:
            VStack(spacing: 3) {
                ForEach(shown) { mark in
                    Capsule()
                        .fill(mark.tag.color.opacity(mark.isFaded ? ScheduleTag.fadedOpacity : 1))
                        .frame(height: barHeight)
                }
                more(shape.more)
            }
        case .details:
            VStack(alignment: .leading, spacing: 2) {
                ForEach(shown) { mark in
                    ScheduleGridEntryTitle(mark: mark)
                }
                more(shape.more)
            }
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
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
