import KanoNaviCore
import SwiftUI

/// The week's entries under day headings, as many lines of them as fit the
/// height offered, up to `lineBudget`. The budget suits the text size; the
/// widget's height, which differs between iPhones and iPads, can leave room
/// for fewer, and whole rows are left out rather than cut through.
struct FittingDayList: View {
    let schedule: WidgetSchedule
    let now: Date
    let today: JapanDate
    let lineBudget: Int
    let excludedID: WidgetItem.ID
    let lastDay: JapanDate

    var body: some View {
        ViewThatFits(in: .vertical) {
            ForEach((0...max(lineBudget, 0)).reversed(), id: \.self) { budget in
                DayGroupedList(
                    days: schedule.upcomingDays(
                        at: now, lineBudget: budget, excluding: excludedID, through: lastDay),
                    today: today, now: now)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}
