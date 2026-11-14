import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One month in any mode, edge to edge, as in Calendar: only its own days in
/// Monday-first weeks (see ``ScheduleMonthWeeks``).
///
/// In a grid mode its short name sits above the column of its first day,
/// its notice comes first when it is not a fresh read, and space follows it
/// before the next month. In List it is just its weeks over a closing
/// hairline. The List month and the grid's months are this one view, so
/// switching modes changes it in place. It takes plain values and compares
/// equal without its actions, so loading one month redraws only that month.
struct ScheduleMonthView: View, Equatable {
    let month: JapanDate
    let today: JapanDate
    let days: ScheduleMonthDays?
    let notice: ScheduleNotice?
    let style: ScheduleMode
    /// Whether its name stands above it, as in a grid mode.
    let showsLabel: Bool
    let selectedDate: JapanDate?
    let contentLanguage: ContentLanguage
    let action: (JapanDate) -> Void
    let page: ((Int) -> Void)?
    let retry: () -> Void

    @Environment(\.locale) private var locale

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.month == rhs.month && lhs.today == rhs.today && lhs.days === rhs.days
            && lhs.notice == rhs.notice && lhs.style == rhs.style && lhs.showsLabel == rhs.showsLabel
            && lhs.selectedDate == rhs.selectedDate && lhs.contentLanguage == rhs.contentLanguage
    }

    var body: some View {
        let weeks = month.monthWeekLayout
        let marks = ScheduleDayMark.marks(
            of: days, weeks: weeks, titlesIn: style == .details ? contentLanguage : nil, locale: locale)
        VStack(alignment: .leading, spacing: 0) {
            if let notice {
                ScheduleStatusNotice(notice: notice, retry: retry)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .transition(.opacity)
            }
            if showsLabel {
                ScheduleGridMonthLabel(month: month, isCurrentMonth: month.isInSameMonth(as: today))
                    .transition(.opacity)
            }
            ScheduleMonthWeeks(
                weeks: weeks, today: today, selectedDate: selectedDate, marks: marks, style: style,
                action: action, page: page)
        }
        .padding(.bottom, style == .list ? 0 : 12)
        .overlay(alignment: .bottom) {
            ScheduleHairline()
                .opacity(style == .list ? 1 : 0)
        }
        // Seven columns cannot grow past this size on an iPhone.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
