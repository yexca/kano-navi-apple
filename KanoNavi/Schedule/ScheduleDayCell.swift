import KanoNaviCore
import SwiftUI

/// One day of the List mode's month, as in Calendar: a hairline above, its
/// number (gray on weekends, in the tint for today), a filled circle when
/// selected (the tint for today, else the primary color), and a dot per
/// entry in its tag color. Takes plain values and compares equal without
/// its action, so selecting a day redraws only the days that change.
struct ScheduleDayCell: View, Equatable {
    let date: JapanDate
    let isToday: Bool
    let isSelected: Bool
    let marks: [ScheduleDayMark]
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var circleSize = 34.0
    @ScaledMetric(relativeTo: .caption2) private var marksHeight = 12.0

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date && lhs.isToday == rhs.isToday && lhs.isSelected == rhs.isSelected
            && lhs.marks == rhs.marks
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(date.day, format: .number)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(numberStyle)
                    .frame(width: circleSize, height: circleSize)
                    .background {
                        if isSelected {
                            Circle().fill(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        }
                    }
                ScheduleDayDots(marks: marks, capacity: ScheduleMode.compact.markCapacity)
                    .frame(height: marksHeight)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 2)
            .overlay(alignment: .top) {
                ScheduleHairline()
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(marks.isEmpty ? Text(verbatim: "") : Text(.Schedule.dayEntryCount(marks.count)))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var numberStyle: AnyShapeStyle {
        if isSelected {
            isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.background)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else if date.isWeekend {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.primary)
        }
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
