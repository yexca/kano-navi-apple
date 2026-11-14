import KanoNaviCore
import SwiftUI

/// The small widget: the live or next entry, its state and its Japan time.
struct SmallUpcomingView: View {
    let entry: UpcomingEntry

    var body: some View {
        Group {
            switch entry.content {
            case .unavailable:
                UnavailableView()
            case .schedule(let schedule):
                if let item = schedule.next(at: entry.date) {
                    HeroEntryView(item: item, now: entry.date, today: entry.today, freshness: schedule)
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
}
