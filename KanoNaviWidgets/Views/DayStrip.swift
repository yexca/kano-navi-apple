import KanoNaviCore
import SwiftUI

/// Seven Japan days in a row, today filled in Berry and a dot under each day
/// with entries. Tapping a day opens the schedule on it.
struct DayStrip: View {
    let days: [WidgetDay]
    let today: JapanDate

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                Link(destination: WidgetDeepLink.schedule(day.date)) {
                    DayStripCell(
                        date: day.date, isToday: day.date == today, hasEntries: day.items.isEmpty == false)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
