import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode, as in Calendar: the month's name, the weekday row and the
/// month on screen fixed at the top, edge to edge, with nothing around them
/// that scrolls, then the month's notice when it is not a fresh read, then
/// the selected day's entries.
///
/// Dragging the month vertically moves it with the finger, the month before
/// or after it following above or below; on release it settles on that
/// month or springs back (see ``ScheduleMonthSwipe``), then grows or
/// shrinks to its weeks.
struct ScheduleListContent: View {
    let model: ScheduleModel
    let contentLanguage: ContentLanguage
    let open: (ScheduleEvent) -> Void
    /// The grid mode this List is turning into or out of. Its month is then
    /// drawn as that mode's month, in place, with the next months below it,
    /// and the day's entries slide away.
    var expansion: ScheduleMode?

    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    /// The month's height at rest, for the drag's threshold and settling.
    @State private var monthHeight: CGFloat = 0
    /// How far the month is moved by a drag or while it settles.
    @State private var dragOffset: CGFloat = 0
    /// Whether the months before and after are drawn, during a drag.
    @State private var showsNeighbours = false
    /// The month area's height while paging: the month's, then the new
    /// month's as it grows or shrinks. `nil` at rest.
    @State private var pinnedHeight: CGFloat?
    /// Whether a page is settling; drags wait until it has.
    @State private var isSettling = false
    /// Whether the current drag is vertical, decided when it starts.
    @State private var isVerticalDrag: Bool?

    var body: some View {
        VStack(spacing: 0) {
            ScheduleMonthHeader(month: model.displayedMonth)
            ScheduleWeekdayRow()
                .padding(.vertical, 6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            ScheduleHairline()
            // The content below may run past the screen while it grows into
            // a grid mode; laid over a view that takes just the space left,
            // it grows down without moving anything above it.
            Color.clear
                .overlay(alignment: .top) {
                    VStack(spacing: 0) {
                        pager
                        if let expansion {
                            nextMonths(expansion)
                        } else {
                            dayEntries
                        }
                    }
                }
                .clipped()
        }
        // Opaque, so it covers the grid exactly while they hand over.
        .background(.background)
        .allowsHitTesting(expansion == nil)
    }

    // MARK: Month

    /// The month on screen, which drags vertically between its neighbours:
    /// while paging, the month before sits above it and the month after
    /// below, all moved together and clipped to the month area.
    private var pager: some View {
        let month = model.displayedMonth
        return VStack(spacing: 0) {
            if showsNeighbours {
                monthView(month.addingMonths(-1), isCurrent: false)
            }
            monthView(month, isCurrent: true)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                    monthHeight = height
                }
            if showsNeighbours {
                monthView(month.addingMonths(1), isCurrent: false)
            }
        }
        .offset(y: showsNeighbours ? dragOffset - previousMonthHeight : 0)
        .frame(height: pinnedHeight, alignment: .top)
        .clipped()
        .contentShape(.rect)
        .highPriorityGesture(drag)
    }

    /// One week row's height in List, from the month on screen.
    private var rowHeight: CGFloat {
        monthHeight / CGFloat(max(model.displayedMonth.monthWeekLayout.count, 1))
    }

    /// The height of the month before the one on screen.
    private var previousMonthHeight: CGFloat {
        rowHeight * CGFloat(model.displayedMonth.addingMonths(-1).monthWeekLayout.count)
    }

    private func monthView(_ month: JapanDate, isCurrent: Bool) -> some View {
        let style = expansion ?? .list
        let notice: ScheduleNotice? = isCurrent && expansion != nil ? model.notice : nil
        let selected = isCurrent ? model.selectedDate : selection(in: month)
        let pageAction: ((Int) -> Void)? = isCurrent ? { page($0) } : nil
        return ScheduleMonthView(
            month: month, today: model.today, days: model.monthDays[month], notice: notice, style: style,
            showsLabel: expansion != nil, selectedDate: selected, contentLanguage: contentLanguage,
            action: { model.select($0) }, page: pageAction, retry: { retry() }
        )
        .equatable()
        .fixedSize(horizontal: false, vertical: true)
    }

    /// The day a month selects when it is paged to: today in today's month,
    /// else its first day.
    private func selection(in month: JapanDate) -> JapanDate {
        model.today.isInSameMonth(as: month) ? model.today : month.firstOfMonth
    }

    /// The months after the one on screen, drawn where a grid mode shows
    /// them while List turns into or out of it.
    private func nextMonths(_ style: ScheduleMode) -> some View {
        ForEach(1...2, id: \.self) { offset in
            let month = model.displayedMonth.addingMonths(offset)
            ScheduleMonthView(
                month: month, today: model.today, days: model.monthDays[month],
                notice: model.notice(for: month), style: style, showsLabel: true, selectedDate: nil,
                contentLanguage: contentLanguage, action: { _ in }, page: nil, retry: {}
            )
            .equatable()
            .fixedSize(horizontal: false, vertical: true)
            .transition(.opacity)
        }
    }

    // MARK: Entries

    @ViewBuilder
    private var dayEntries: some View {
        VStack(spacing: 0) {
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: Paging

    private var drag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                if isVerticalDrag == nil {
                    isVerticalDrag = abs(value.translation.height) > abs(value.translation.width)
                }
                guard isVerticalDrag == true, isSettling == false, reducesMotion == false else { return }
                if showsNeighbours == false {
                    pinnedHeight = monthHeight
                    showsNeighbours = true
                }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                defer { isVerticalDrag = nil }
                guard isVerticalDrag == true, isSettling == false else { return }
                page(
                    ScheduleMonthSwipe.offset(
                        translation: value.translation.height,
                        predicted: value.predictedEndTranslation.height, height: monthHeight))
            }
    }

    /// Pages `direction` months, from wherever a drag left the month: it
    /// slides to the month after or before it, or back to rest, then grows
    /// or shrinks to the new month's weeks. Reduce Motion cross-fades.
    private func page(_ direction: Int) {
        if reducesMotion {
            guard direction != 0 else { return }
            withAnimation(ScheduleModeSwitch.crossFadeAnimation) { model.showMonth(offset: direction) }
            return
        }
        let rowHeight = rowHeight
        let previousHeight = previousMonthHeight
        isSettling = true
        if showsNeighbours == false {
            pinnedHeight = monthHeight
            showsNeighbours = true
        }
        withAnimation(ScheduleMonthSwipe.settleAnimation, completionCriteria: .logicallyComplete) {
            dragOffset = ScheduleMonthSwipe.settledOffset(
                direction: direction, height: monthHeight, previousHeight: previousHeight)
        } completion: {
            finishPage(direction, rowHeight: rowHeight)
        }
    }

    /// Swaps in the month the drag settled on, which is drawn exactly where
    /// its neighbour was, then fits the month area to its weeks.
    private func finishPage(_ direction: Int, rowHeight: CGFloat) {
        var swap = Transaction()
        swap.disablesAnimations = true
        withTransaction(swap) {
            if direction != 0 {
                model.showMonth(offset: direction)
            }
            dragOffset = 0
            showsNeighbours = false
        }
        let height = rowHeight * CGFloat(model.displayedMonth.monthWeekLayout.count)
        withAnimation(ScheduleMonthSwipe.resizeAnimation, completionCriteria: .logicallyComplete) {
            pinnedHeight = height
        } completion: {
            pinnedHeight = nil
            isSettling = false
        }
    }

    private func retry() {
        Task { await model.refresh() }
    }
}
