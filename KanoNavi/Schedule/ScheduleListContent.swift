import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode, as in Calendar: the month's name, the weekday row and the
/// month on screen fixed at the top, edge to edge, with nothing around them
/// that scrolls, then the month's notice when it is not
/// a fresh read, then the selected day's entries. Swiping the month up shows
/// the next month and down the previous one.
struct ScheduleListContent: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void
    /// The grid mode this List is turning into or out of. Its month is then
    /// drawn as that mode's month, the weeks paired with `morph` so they grow
    /// or shrink in place, and the day's entries slide away.
    var expansion: ScheduleMode?
    var morph: Namespace.ID?

    /// Where the next month slides in from.
    @State private var pageEdge = Edge.bottom

    var body: some View {
        VStack(spacing: 0) {
            ScheduleMonthHeader(month: model.displayedMonth)
            ScheduleWeekdayRow()
                .padding(.vertical, 6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            ScheduleHairline()
            if let expansion {
                // The grown months run past the screen; laid over a view that
                // takes just the space left, they grow down without moving
                // anything above them.
                Color.clear
                    .overlay(alignment: .top) {
                        expandedMonth(expansion)
                    }
                    .clipped()
            } else {
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
                    refresh: model.refresh
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // Opaque, so it covers the grid exactly while they hand over.
        .background(.background)
    }

    /// The month on screen drawn as the grid mode's month, with the next
    /// months below it fading in or out, exactly where the grid shows them.
    private func expandedMonth(_ style: ScheduleMode) -> some View {
        let month = model.displayedMonth
        return VStack(spacing: 0) {
            gridMonth(month, style: style, morph: morph)
            ForEach(1...2, id: \.self) { offset in
                gridMonth(month.addingMonths(offset), style: style, morph: nil)
                    .transition(.opacity)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .allowsHitTesting(false)
    }

    private func gridMonth(_ month: JapanDate, style: ScheduleMode, morph: Namespace.ID?) -> some View {
        ScheduleGridMonth(
            month: month, today: model.today, days: model.monthDays[month], notice: nil, style: style,
            contentLanguage: contentLanguage, openDay: { _ in }, retry: {}, morph: morph
        )
        .equatable()
    }

    private var month: some View {
        let month = model.displayedMonth
        let weeks = month.monthWeekLayout
        return ZStack(alignment: .top) {
            ScheduleMonthGrid(
                weeks: weeks, today: model.today, selectedDate: model.selectedDate,
                marks: ScheduleDayMark.marks(of: model.monthDays[month], weeks: weeks),
                select: model.select, page: page, morph: morph
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
