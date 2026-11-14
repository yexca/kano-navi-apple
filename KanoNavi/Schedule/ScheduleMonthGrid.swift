import KanoNaviCore
import SwiftUI

/// The List mode's month, edge to edge: only the month's own days in
/// Monday-first weeks, with blank places before its first day and after its
/// last. Every day offers VoiceOver actions for the previous and next
/// month, since swiping the grid pages by month.
struct ScheduleMonthGrid: View, Equatable {
    let weeks: [[JapanDate?]]
    let today: JapanDate
    let selectedDate: JapanDate
    let marks: [JapanDate: [ScheduleDayMark]]
    let select: (JapanDate) -> Void
    let page: (Int) -> Void

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.weeks == rhs.weeks && lhs.today == rhs.today && lhs.selectedDate == rhs.selectedDate
            && lhs.marks == rhs.marks
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(weeks.enumerated(), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(week.enumerated(), id: \.offset) { _, date in
                        if let date {
                            ScheduleDayCell(
                                date: date, isToday: date == today, isSelected: date == selectedDate,
                                marks: marks[date] ?? []
                            ) {
                                select(date)
                            }
                            .equatable()
                            .accessibilityAction(named: Text(.Schedule.previousMonth)) { page(-1) }
                            .accessibilityAction(named: Text(.Schedule.nextMonth)) { page(1) }
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay(alignment: .bottom) {
            ScheduleHairline()
        }
    }
}
