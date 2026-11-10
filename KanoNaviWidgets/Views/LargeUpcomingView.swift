import KanoNaviCore
import SwiftUI

/// The large widget: the seven Japan days from today with their entries. At
/// accessibility sizes, where seven day rows cannot fit, it lists the next
/// entries by day instead.
struct LargeUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        switch entry.content {
        case .unavailable:
            UnavailableView()
        case .schedule(let schedule):
            VStack(alignment: .leading, spacing: 6) {
                ListHeader(schedule: schedule, isCompact: dynamicTypeSize.isAccessibilitySize)
                if dynamicTypeSize.isAccessibilitySize {
                    let days = schedule.upcomingDays(
                        at: entry.date, lineBudget: WidgetLineBudget.large(dynamicTypeSize),
                        itemLines: WidgetLineBudget.itemLines(dynamicTypeSize))
                    if days.isEmpty {
                        NothingScheduledView()
                    } else {
                        StackedDayList(days: days, today: entry.today, now: entry.date)
                    }
                } else {
                    WeekGrid(
                        days: schedule.week(
                            at: entry.date, lineBudget: WidgetLineBudget.large(dynamicTypeSize)),
                        today: entry.today, now: entry.date)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
