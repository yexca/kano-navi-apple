import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode, as in Calendar: the weekday row and the month on screen
/// fixed at the top, edge to edge, then the month's notice when it is not
/// a fresh read, then the selected day's entries. Swiping the month up shows
/// the next month and down the previous one.
struct ScheduleListContent: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void

    /// Where the next month slides in from.
    @State private var pageEdge = Edge.bottom

    var body: some View {
        VStack(spacing: 0) {
            ScheduleWeekdayRow()
                .padding(.vertical, 6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            ScheduleHairline()
            month
            if let notice = model.notice {
                ScheduleStatusNotice(notice: notice, retry: retry)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScheduleHairline()
            }
            ScheduleDayList(
                entries: model.entries(on: model.selectedDate), isLoading: model.isLoading,
                isLoaded: model.month != nil, contentLanguage: contentLanguage, open: open,
                refresh: model.refresh)
        }
    }

    private var month: some View {
        let month = model.displayedMonth
        let weeks = month.monthWeekLayout
        return ZStack(alignment: .top) {
            ScheduleMonthGrid(
                weeks: weeks, today: model.today, selectedDate: model.selectedDate,
                marks: ScheduleDayMark.marks(of: model.monthDays[month], weeks: weeks),
                select: model.select, page: page
            )
            .equatable()
            .id(month)
            .transition(.push(from: pageEdge))
        }
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard abs(value.translation.height) > abs(value.translation.width) else { return }
                    page(
                        ScheduleMonthSwipe.offset(
                            translation: value.translation.height,
                            predicted: value.predictedEndTranslation.height))
                }
        )
        .clipped()
        // Seven columns of numbers cannot grow past this size on an iPhone;
        // the entries below keep the full text size.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    /// Pages `offset` months, sliding the new month in from below for a
    /// later month and from above for an earlier one.
    private func page(_ offset: Int) {
        guard offset != 0 else { return }
        pageEdge = offset > 0 ? .bottom : .top
        withAnimation(.snappy(duration: 0.3)) {
            model.showMonth(offset: offset)
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
