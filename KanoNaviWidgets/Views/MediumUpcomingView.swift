import KanoNaviCore
import SwiftUI

/// The medium widget: the live or next entry beside the entries that follow
/// it. At accessibility sizes it lists the next entries by day instead.
struct MediumUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            switch entry.content {
            case .unavailable:
                UnavailableView()
            case .schedule(let schedule):
                if dynamicTypeSize.isAccessibilitySize {
                    stacked(schedule)
                } else if let hero = schedule.next(at: entry.date) {
                    columns(schedule, hero: hero)
                } else {
                    VStack(alignment: .leading) {
                        NothingScheduledView()
                        FreshnessLabel(schedule: schedule)
                    }
                }
            }
        }
        .fontDesign(.rounded)
        // Links would otherwise draw their labels in the accent color.
        .tint(.primary)
    }

    private func columns(_ schedule: WidgetSchedule, hero: WidgetItem) -> some View {
        let limit = WidgetLineBudget.mediumFollowing(dynamicTypeSize) - (schedule.isStale ? 1 : 0)
        return HStack(spacing: 12) {
            Link(destination: hero.url) {
                HeroEntryView(item: hero, now: entry.date, today: entry.today)
            }
            Divider()
            FollowingList(
                items: schedule.following(hero, at: entry.date, limit: max(limit, 1)), schedule: schedule,
                now: entry.date, today: entry.today)
        }
    }

    private func stacked(_ schedule: WidgetSchedule) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            WidgetHeader(title: .widgetUpcomingName, schedule: schedule)
            let days = schedule.upcomingDays(
                at: entry.date, lineBudget: WidgetLineBudget.mediumStacked,
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
