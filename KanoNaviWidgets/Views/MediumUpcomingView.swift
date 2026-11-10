import KanoNaviCore
import SwiftUI

/// The medium widget: the next entries grouped by Japan day.
struct MediumUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        switch entry.content {
        case .unavailable:
            UnavailableView()
        case .schedule(let schedule):
            VStack(alignment: .leading, spacing: 4) {
                ListHeader(schedule: schedule, isCompact: dynamicTypeSize.isAccessibilitySize)
                let days = schedule.upcomingDays(
                    at: entry.date, lineBudget: WidgetLineBudget.medium(dynamicTypeSize),
                    itemLines: WidgetLineBudget.itemLines(dynamicTypeSize))
                if days.isEmpty {
                    NothingScheduledView()
                } else if dynamicTypeSize.isAccessibilitySize {
                    StackedDayList(days: days, today: entry.today, now: entry.date)
                } else {
                    DayGroupedList(days: days, today: entry.today, now: entry.date)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
