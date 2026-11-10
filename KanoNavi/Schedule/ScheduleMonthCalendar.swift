import KanoNaviCore
import SwiftUI

/// The month header with paging buttons, the Monday-first weekday row and
/// the six-week grid of Japan dates.
struct ScheduleMonthCalendar: View {
    let model: ScheduleModel

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 8) {
            header
            Grid(horizontalSpacing: 0, verticalSpacing: 4) {
                GridRow {
                    ForEach(weekdaySymbols.enumerated(), id: \.offset) { _, symbol in
                        Text(verbatim: symbol)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .accessibilityHidden(true)
                    }
                }
                ForEach(weeks, id: \.first) { week in
                    GridRow {
                        ForEach(week, id: \.self) { date in
                            ScheduleDayCell(
                                date: date,
                                isInDisplayedMonth: date.isInSameMonth(as: model.displayedMonth),
                                isToday: date == model.today,
                                isSelected: date == model.selectedDate,
                                entryCount: model.count(on: date)
                            ) {
                                model.select(date)
                            }
                        }
                    }
                }
            }
            // Seven columns of numbers cannot grow past this size on an iPhone;
            // the entries below the grid keep the full text size.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }

    private var header: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 0))
        return layout {
            Text(verbatim: model.displayedMonth.monthTitle(locale: locale))
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 16) {
                Button(.Schedule.previousMonth, systemImage: "chevron.left") {
                    model.showMonth(offset: -1)
                }
                Button(.Schedule.nextMonth, systemImage: "chevron.right") {
                    model.showMonth(offset: 1)
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .font(.title3)
        }
    }

    /// The grid's six weeks of seven days.
    private var weeks: [[JapanDate]] {
        let dates = model.gridDates
        return stride(from: 0, to: dates.count, by: 7).map { Array(dates[$0..<min($0 + 7, dates.count)]) }
    }

    /// Very short weekday symbols in the interface language, Monday first.
    private var weekdaySymbols: [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return Array(symbols.dropFirst()) + symbols.prefix(1)
    }
}
