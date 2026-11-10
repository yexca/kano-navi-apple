import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import WidgetKit

/// The small widget's time: when a live entry ends, or the next entry's day,
/// Japan time and countdown.
struct SmallTimeBlock: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.isLive(at: now) {
                if let endsAt = item.endsAt {
                    Text(.widgetEndsAt(JSTTimeFormat.time(endsAt, locale: locale)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                if item.day != today {
                    DayLabel(date: item.day, today: today)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                // The time scales down rather than truncating.
                EntryTime(item: item, now: now, labelsZone: true)
                    .font(.title3.weight(.bold))
                    .minimumScaleFactor(0.5)
                    .widgetAccentable()
                if let startsAt = item.startsAt, startsAt.timeIntervalSince(now) < 24 * 60 * 60 {
                    Text(.currentDate, format: .reference(to: startsAt, allowedFields: [.hour, .minute]))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}
