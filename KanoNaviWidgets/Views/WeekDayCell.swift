import KanoNaviCore
import SwiftUI

/// The day column of the week view: "Today" or the weekday, then the day.
struct WeekDayCell: View {
    let date: JapanDate
    let today: JapanDate

    @Environment(\.locale) private var locale

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Group {
                if date == today {
                    Text(.widgetToday)
                } else {
                    Text(WidgetFormat.weekday(date, locale: locale))
                }
            }
            .font(.caption2.weight(.semibold))
            Text(date.day, format: .number)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(date == today ? Color.primary : Color.secondary)
        .fixedSize()
    }
}
