import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One month of the vertically scrolling grid, as in Calendar: its short
/// name above the column of its first day, then only its own days in
/// Monday-first weeks, a hairline above each day, the places of the months
/// around it left blank. The month's notice comes first when it is not a
/// fresh read. Takes plain values and compares equal without its actions,
/// so loading one month redraws only that month.
struct ScheduleGridMonth: View, Equatable {
    let month: JapanDate
    let today: JapanDate
    let days: ScheduleMonthDays?
    let notice: ScheduleNotice?
    let style: ScheduleMode
    let contentLanguage: ContentLanguage
    let openDay: (JapanDate) -> Void
    let retry: () -> Void
    /// Pairs the weeks with the List mode's while modes switch.
    var morph: Namespace.ID?

    @Environment(\.locale) private var locale

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.month == rhs.month && lhs.today == rhs.today && lhs.days === rhs.days
            && lhs.notice == rhs.notice && lhs.style == rhs.style
            && lhs.contentLanguage == rhs.contentLanguage
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
            }
            ScheduleGridMonthLabel(month: month, isCurrentMonth: month.isInSameMonth(as: today))
            ForEach(weeks.enumerated(), id: \.offset) { _, week in
                ScheduleGridWeek(
                    week: week, today: today, marks: marks, style: style, openDay: openDay, morph: morph)
            }
        }
        // Seven columns cannot grow past this size on an iPhone.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .padding(.bottom, 12)
    }
}
