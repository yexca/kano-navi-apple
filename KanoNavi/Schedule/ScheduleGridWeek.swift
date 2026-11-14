import KanoNaviCore
import SwiftUI

/// One week of a vertically scrolling month: its days, with blank places
/// for the days of the months around it.
struct ScheduleGridWeek: View {
    let week: [JapanDate?]
    let today: JapanDate
    let marks: [JapanDate: [ScheduleDayMark]]
    let style: ScheduleMode
    let openDay: (JapanDate) -> Void
    /// Pairs this week with its List mode twin while modes switch.
    var morph: Namespace.ID?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(week.enumerated(), id: \.offset) { _, date in
                if let date {
                    ScheduleGridDayCell(
                        date: date, isToday: date == today, marks: marks[date] ?? [], style: style
                    ) {
                        openDay(date)
                    }
                    .equatable()
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: 0)
                        .accessibilityHidden(true)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .scheduleWeekMorph(week, in: morph)
    }
}
