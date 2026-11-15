import KanoNaviCore
import SwiftUI

/// The extra-large widget on iPad: the large widget's header and strip of
/// the seven Japan days across its width, then the live or next entry's card
/// beside the week's other entries by day, which get the room of both. At
/// accessibility sizes, and when the schedule cannot be read, it shows the
/// large widget's layout.
struct ExtraLargeUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale

    var body: some View {
        if case .schedule(let schedule) = entry.content, dynamicTypeSize.isAccessibilitySize == false {
            week(schedule)
                .fontDesign(.rounded)
                // Links would otherwise draw their labels in the accent color.
                .tint(.primary)
        } else {
            LargeUpcomingView(entry: entry)
        }
    }

    private func week(_ schedule: WidgetSchedule) -> some View {
        let lastDay = entry.today.addingDays(6)
        return VStack(alignment: .leading, spacing: 10) {
            WidgetHeader(
                title: .widgetThisWeek, schedule: schedule,
                detail: WidgetFormat.dayRange(from: entry.today, through: lastDay, locale: locale))
            DayStrip(days: schedule.week(at: entry.date), today: entry.today)
            if let hero = schedule.next(at: entry.date) {
                HStack(alignment: .top, spacing: 16) {
                    Link(destination: hero.url) {
                        HeroCard(item: hero, now: entry.date, today: entry.today)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    FittingDayList(
                        schedule: schedule, now: entry.date, today: entry.today,
                        lineBudget: WidgetLineBudget.extraLarge(dynamicTypeSize), excludedID: hero.id,
                        lastDay: lastDay
                    )
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                NothingScheduledView()
            }
        }
    }
}
