import KanoNaviCore
import SwiftUI

/// One month of the List mode: its six-week grid of Japan dates, with a mark
/// on each day that has entries. Every day also offers VoiceOver actions for
/// the previous and next month, since swiping the grid pages by month.
struct ScheduleMonthPage: View {
    let month: JapanDate
    let model: ScheduleModel

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 4) {
            ForEach(weeks, id: \.first) { week in
                GridRow {
                    ForEach(week, id: \.self) { date in
                        ScheduleDayCell(
                            date: date,
                            isInDisplayedMonth: date.isInSameMonth(as: month),
                            isToday: date == model.today,
                            isSelected: date == model.selectedDate,
                            entryCount: model.count(on: date)
                        ) {
                            model.select(date)
                        }
                        .accessibilityAction(named: Text(.Schedule.previousMonth)) {
                            model.showMonth(offset: -1)
                        }
                        .accessibilityAction(named: Text(.Schedule.nextMonth)) {
                            model.showMonth(offset: 1)
                        }
                    }
                }
            }
        }
    }

    /// The month's six weeks of seven days.
    private var weeks: [[JapanDate]] {
        let dates = month.monthGrid
        return stride(from: 0, to: dates.count, by: 7).map { Array(dates[$0..<min($0 + 7, dates.count)]) }
    }
}
