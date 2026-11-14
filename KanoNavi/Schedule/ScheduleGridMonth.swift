import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One month of the vertically scrolling grid: its short name above the
/// column of its first day, then its weeks with a line above each. Days of
/// the months around it stay blank, so months follow on as in Calendar. The
/// month's notice comes first when it is not a fresh read.
struct ScheduleGridMonth: View {
    let month: JapanDate
    let model: ScheduleModel
    let style: ScheduleMode
    let contentLanguage: ContentLanguage
    let openDay: (JapanDate) -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let notice = model.notice(for: month) {
                ScheduleStatusNotice(notice: notice, retry: retry)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(0..<firstColumn, id: \.self) { _ in
                        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                    }
                    Text(verbatim: month.shortMonthTitle(locale: locale))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(
                            month.isInSameMonth(as: model.today)
                                ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .gridCellColumns(7 - firstColumn)
                        .accessibilityLabel(Text(verbatim: month.monthTitle(locale: locale)))
                        .accessibilityAddTraits(.isHeader)
                }
                ForEach(month.monthWeeks, id: \.first) { week in
                    Divider()
                    GridRow {
                        ForEach(week, id: \.self) { date in
                            if date.isInSameMonth(as: month) {
                                ScheduleGridDayCell(
                                    date: date,
                                    isToday: date == model.today,
                                    entries: model.entries(on: date),
                                    style: style,
                                    contentLanguage: contentLanguage
                                ) {
                                    openDay(date)
                                }
                            } else {
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                            }
                        }
                    }
                }
            }
            // Seven columns cannot grow past this size on an iPhone.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .padding(.bottom, 12)
    }

    /// The Monday-first column of the month's first day.
    private var firstColumn: Int {
        month.monthWeeks.first?.firstIndex(of: month.firstOfMonth) ?? 0
    }

    private func retry() {
        Task { await model.load(month) }
    }
}
