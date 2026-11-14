import KanoNaviCore
import SwiftUI

/// A month's Monday-first weeks of ``ScheduleDayCell``s, with blank places
/// before its first day and after its last, in any mode. In List, each day
/// also offers VoiceOver actions for the previous and next month, since
/// swiping the month pages it.
struct ScheduleMonthWeeks: View {
    let weeks: [[JapanDate?]]
    let today: JapanDate
    /// The selected day, shown only in List.
    let selectedDate: JapanDate?
    let marks: [JapanDate: [ScheduleDayMark]]
    let style: ScheduleMode
    let action: (JapanDate) -> Void
    /// Pages by months, for VoiceOver; `nil` where swiping does not page.
    let page: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeks.enumerated(), id: \.offset) { _, week in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(week.enumerated(), id: \.offset) { _, date in
                        if let date {
                            cell(date)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: 0)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func cell(_ date: JapanDate) -> some View {
        let cell = ScheduleDayCell(
            date: date, isToday: date == today, isSelected: date == selectedDate, marks: marks[date] ?? [],
            style: style
        ) {
            action(date)
        }
        .equatable()
        if let page {
            cell
                .accessibilityAction(named: Text(.Schedule.previousMonth)) { page(-1) }
                .accessibilityAction(named: Text(.Schedule.nextMonth)) { page(1) }
        } else {
            cell
        }
    }
}
