import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// When an upcoming entry starts, relative to now: a countdown for an entry
/// later today, or "Today" where the countdown does not fit, or the day of a
/// later entry.
struct EntryWhen: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate

    var body: some View {
        Group {
            if item.day <= today, let startsAt = item.startsAt, startsAt > now,
                JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: item.timePrecision)
            {
                ViewThatFits(in: .horizontal) {
                    Text(
                        .currentDate,
                        format: .reference(to: startsAt, allowedFields: [.hour, .minute], maxFieldCount: 1))
                    day
                }
            } else {
                day
            }
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var day: some View {
        DayLabel(date: max(item.day, today), today: today, isCompact: true)
    }
}
