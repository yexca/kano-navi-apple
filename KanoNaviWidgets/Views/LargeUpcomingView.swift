import KanoNaviCore
import SwiftUI

/// The large widget: the seven Japan days from today as a strip, the live or
/// next entry, and the week's other entries by day. At accessibility sizes,
/// where the strip and card leave no room, it lists the next entries by day
/// instead.
struct LargeUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale

    var body: some View {
        Group {
            switch entry.content {
            case .unavailable:
                UnavailableView()
            case .schedule(let schedule):
                if dynamicTypeSize.isAccessibilitySize {
                    stacked(schedule)
                } else {
                    week(schedule)
                }
            }
        }
        .fontDesign(.rounded)
        // Links would otherwise draw their labels in the accent color.
        .tint(.primary)
    }

    private func week(_ schedule: WidgetSchedule) -> some View {
        let lastDay = entry.today.addingDays(6)
        return VStack(alignment: .leading, spacing: 10) {
            WidgetHeader(
                title: .widgetThisWeek, schedule: schedule,
                detail: WidgetFormat.dayRange(from: entry.today, through: lastDay, locale: locale))
            DayStrip(days: schedule.week(at: entry.date), today: entry.today)
            if let hero = schedule.next(at: entry.date) {
                Link(destination: hero.url) {
                    HeroCard(item: hero, now: entry.date, today: entry.today)
                }
                FittingDayList(
                    schedule: schedule, now: entry.date, today: entry.today,
                    lineBudget: WidgetLineBudget.large(dynamicTypeSize), excludedID: hero.id,
                    lastDay: lastDay)
            } else {
                NothingScheduledView()
            }
        }
    }

    private func stacked(_ schedule: WidgetSchedule) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader(title: .widgetUpcomingName, schedule: schedule)
            let days = schedule.upcomingDays(
                at: entry.date, lineBudget: WidgetLineBudget.large(dynamicTypeSize),
                itemLines: WidgetLineBudget.itemLines(dynamicTypeSize))
            if days.isEmpty {
                NothingScheduledView()
            } else {
                StackedDayList(days: days, today: entry.today, now: entry.date)
            }
            Spacer(minLength: 0)
        }
    }
}
