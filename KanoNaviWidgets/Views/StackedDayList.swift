import KanoNaviCore
import SwiftUI
import WidgetKit

/// Entries under day headings with each Japan time above its title, for
/// accessibility text sizes where a time column would squeeze the titles.
struct StackedDayList: View {
    let days: [WidgetDay]
    let today: JapanDate
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(days) { day in
                DayLabel(date: day.date, today: today)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(day.items) { item in
                    Link(destination: item.url) {
                        VStack(alignment: .leading, spacing: 0) {
                            EntryTime(item: item, now: now, labelsZone: true)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                                .widgetAccentable()
                            EntryTitle(item: item)
                        }
                    }
                }
            }
        }
        .font(.footnote)
    }
}
