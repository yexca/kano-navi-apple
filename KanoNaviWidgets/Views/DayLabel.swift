import KanoNaviCore
import SwiftUI

/// "Today", "Tomorrow" or the weekday and date of a Japan day.
struct DayLabel: View {
    let date: JapanDate
    let today: JapanDate

    @Environment(\.locale) private var locale

    var body: some View {
        if date == today {
            Text(.widgetToday)
        } else if date == today.addingDays(1) {
            Text(.widgetTomorrow)
        } else {
            Text(WidgetFormat.day(date, locale: locale))
        }
    }
}
