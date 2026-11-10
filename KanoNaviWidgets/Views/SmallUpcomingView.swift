import KanoNaviCore
import SwiftUI

/// The small widget: the live or next entry, its Japan time and a countdown.
struct SmallUpcomingView: View {
    let entry: UpcomingEntry

    var body: some View {
        switch entry.content {
        case .unavailable:
            UnavailableView()
        case .schedule(let schedule):
            if let item = schedule.next(at: entry.date) {
                SmallEntryView(item: item, schedule: schedule, now: entry.date, today: entry.today)
            } else {
                VStack(alignment: .leading) {
                    NothingScheduledView()
                    FreshnessLabel(schedule: schedule)
                }
            }
        }
    }
}
