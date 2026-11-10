import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Lock Screen's time line: when a live entry ends, or the next entry's
/// day and Japan time.
struct RectangularTimeLine: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate

    @Environment(\.locale) private var locale

    var body: some View {
        if item.isLive(at: now) {
            if let endsAt = item.endsAt {
                Text(.widgetEndsAt(JSTTimeFormat.time(endsAt, locale: locale)))
            }
        } else {
            HStack(spacing: 4) {
                if item.day != today {
                    DayLabel(date: item.day, today: today)
                }
                EntryTime(item: item, now: now, labelsZone: true)
            }
        }
    }
}
