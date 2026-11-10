import KanoNaviCore
import SwiftUI
import WidgetKit

/// Seven Japan days in rows, each with its entries or "No entries".
struct WeekGrid: View {
    let days: [WidgetDay]
    let today: JapanDate
    let now: Date

    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 8, verticalSpacing: 6) {
            ForEach(days) { day in
                if day.items.isEmpty {
                    GridRow {
                        WeekDayCell(date: day.date, today: today)
                        Text(.widgetNoEntries)
                            .foregroundStyle(Color.secondary.opacity(0.7))
                            .gridCellColumns(2)
                    }
                } else {
                    ForEach(day.items) { item in
                        GridRow {
                            WeekDayCell(date: day.date, today: today)
                                .opacity(item.id == day.items.first?.id ? 1 : 0)
                                .accessibilityHidden(item.id != day.items.first?.id)
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
                                    if item.id == day.items.last?.id, day.hiddenCount > 0 {
                                        Text(.widgetMoreCount(day.hiddenCount))
                                            .font(.caption2)
                                            .foregroundStyle(Color.secondary)
                                            .lineLimit(1)
                                            .fixedSize()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .font(.subheadline)
    }
}
