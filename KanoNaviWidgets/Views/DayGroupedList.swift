import KanoNaviCore
import SwiftUI
import WidgetKit

/// Entries under compact day headings, with their times in one aligned
/// Berry column.
struct DayGroupedList: View {
    let days: [WidgetDay]
    let today: JapanDate
    let now: Date

    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 10, verticalSpacing: 3) {
            ForEach(days) { day in
                DayLabel(date: day.date, today: today, isCompact: true)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.top, day.id == days.first?.id ? 0 : 4)
                    .gridCellColumns(2)
                ForEach(day.items) { item in
                    GridRow {
                        Link(destination: item.url) {
                            EntryTime(item: item, now: now)
                                .fontWeight(.bold)
                                .berryForeground()
                        }
                        .fixedSize()
                        Link(destination: item.url) {
                            HStack(spacing: 4) {
                                EntryTitle(item: item)
                                    .fontWeight(.medium)
                                EntryMarks(item: item)
                            }
                        }
                    }
                }
            }
        }
        .font(.subheadline)
    }
}
