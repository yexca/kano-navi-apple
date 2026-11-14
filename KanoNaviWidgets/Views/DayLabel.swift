import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// "Today", "Tomorrow" or the weekday and date of a Japan day.
struct DayLabel: View {
    let date: JapanDate
    let today: JapanDate
    /// Whether to show a later day as its weekday and day of the month, such
    /// as "Sun 15", instead of with its month.
    var isCompact = false

    @Environment(\.locale) private var locale

    var body: some View {
        if date == today {
            Text(.widgetToday)
        } else if date == today.addingDays(1) {
            Text(.widgetTomorrow)
        } else if isCompact {
            Text(WidgetFormat.shortDay(date, locale: locale))
        } else {
            Text(JSTTimeFormat.day(date, locale: locale))
        }
    }
}
