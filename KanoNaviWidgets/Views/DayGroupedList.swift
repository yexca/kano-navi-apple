import KanoNaviCore
import SwiftUI
import WidgetKit

/// Entries under day headings, with their times in one aligned column.
struct DayGroupedList: View {
    let days: [WidgetDay]
    let today: JapanDate
    let now: Date

    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 8, verticalSpacing: 2) {
            ForEach(days) { day in
                DayLabel(date: day.date, today: today)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, day.id == days.first?.id ? 0 : 3)
                    .gridCellColumns(2)
                ForEach(day.items) { item in
                    GridRow {
                        Link(destination: item.url) {
                            EntryTime(item: item, now: now)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                                .widgetAccentable()
                        }
                        .fixedSize()
                        Link(destination: item.url) {
                            HStack(spacing: 4) {
                                EntryTitle(item: item)
                                EntryMarks(item: item)
                            }
                        }
                    }
                }
            }
        }
        .font(.footnote)
    }
}
