import KanoNaviCore
import SwiftUI

/// One day of the month grid: its number, a mark when it has entries, a
/// ring for today and a filled circle when selected.
struct ScheduleDayCell: View {
    let date: JapanDate
    let isInDisplayedMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let entryCount: Int
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var circleSize = 36.0
    @ScaledMetric(relativeTo: .body) private var markSize = 5.0

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
                Circle()
                    .fill(entryCount > 0 ? AnyShapeStyle(markStyle) : AnyShapeStyle(.clear))
                    .frame(width: markSize, height: markSize)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(entryCount > 0 ? Text(.Schedule.dayEntryCount(entryCount)) : Text(verbatim: ""))
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

    private var markStyle: AnyShapeStyle {
        isInDisplayedMonth ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary)
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
