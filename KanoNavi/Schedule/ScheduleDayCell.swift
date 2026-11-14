import KanoNaviCore
import SwiftUI

/// One day of the List mode's month: its number, a ring for today, a filled
/// circle when selected, and its entries as dots in their tag colors (see
/// ``ScheduleDayDots``), gray on the days of the months around it.
struct ScheduleDayCell: View {
    let date: JapanDate
    let isInDisplayedMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let entries: [ScheduleDayEntry]
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var circleSize = 36.0
    @ScaledMetric(relativeTo: .caption2) private var marksHeight = 13.0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(date.day, format: .number)
                    .font(.body.weight(isToday || isSelected ? .semibold : .regular))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(numberStyle)
                    .frame(width: circleSize, height: circleSize)
                    .background {
                        if isSelected {
                            Circle().fill(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        } else if isToday {
                            Circle().strokeBorder(.tint, lineWidth: 1.5)
                        }
                    }
                ScheduleDayDots(
                    entries: entries, capacity: ScheduleMode.compact.markCapacity,
                    isMuted: isInDisplayedMonth == false
                )
                .frame(height: marksHeight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(
            entries.isEmpty ? Text(verbatim: "") : Text(.Schedule.dayEntryCount(entries.count))
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var numberStyle: AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(.background)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else if isInDisplayedMonth {
            AnyShapeStyle(.primary)
        } else {
            AnyShapeStyle(.tertiary)
        }
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
