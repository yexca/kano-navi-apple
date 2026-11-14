import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The List mode's month, which a vertical drag moves with the finger, as in
/// Calendar: the month before sits above it and the month after below,
/// already drawn and indexed, so a drag only moves them. Past the threshold
/// it reports the month a release would show, for the header; on release it
/// settles on that month, or springs back, with the finger's speed, the area
/// growing or shrinking to the new month's weeks in the same motion.
///
/// While List turns into a grid mode it draws just the month on screen, as
/// that mode's month.
struct ScheduleMonthPager: View {
    let model: ScheduleModel
    let expansion: ScheduleMode?
    let contentLanguage: ContentLanguage
    /// The month a release would show, against the month on screen: -1, 0
    /// or 1.
    @Binding var preview: Int

    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    /// One week row's height in List, measured from the month on screen.
    @State private var rowHeight: CGFloat = 0
    /// How far a drag, or the settling after it, has moved the months.
    @State private var dragOffset: CGFloat = 0
    /// The month area's height while settling, moving to the new month's.
    @State private var settlingHeight: CGFloat?
    /// Whether a page is settling; drags wait until it has.
    @State private var isSettling = false
    /// Whether the current drag is vertical, decided when it starts.
    @State private var isVerticalDrag: Bool?

    private var isList: Bool { expansion == nil }

    var body: some View {
        let month = model.displayedMonth
        let months = isList ? [month.addingMonths(-1), month, month.addingMonths(1)] : [month]
        ZStack(alignment: .top) {
            ForEach(months, id: \.self) { page in
                monthView(page, isCurrent: page == month)
                    .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                        if isList, page == model.displayedMonth {
                            rowHeight = height / CGFloat(max(page.monthWeekLayout.count, 1))
                        }
                    }
                    .offset(y: position(of: page, from: month))
                    // The neighbours wait for the first measure to be placed.
                    .opacity(page == month || rowHeight > 0 ? 1 : 0)
            }
        }
        .offset(y: dragOffset)
        .frame(height: areaHeight(for: month), alignment: .top)
        .clipped()
        .contentShape(.rect)
        .highPriorityGesture(drag, isEnabled: isList)
    }

    private func monthView(_ month: JapanDate, isCurrent: Bool) -> some View {
        let notice: ScheduleNotice? = isCurrent && expansion != nil ? model.notice : nil
        let selected = isCurrent ? model.selectedDate : selection(in: month)
        let pageAction: ((Int) -> Void)? = isCurrent ? { page($0, velocity: 0) } : nil
        return ScheduleMonthView(
            month: month, today: model.today, days: model.monthDays[month], notice: notice,
            style: expansion ?? .list, showsLabel: expansion != nil, selectedDate: selected,
            contentLanguage: contentLanguage, action: { model.select($0) }, page: pageAction,
            retry: { Task { await model.refresh() } }
        )
        .equatable()
        .fixedSize(horizontal: false, vertical: true)
    }

    /// The day a month selects when it is paged to: today in today's month,
    /// else its first day.
    private func selection(in month: JapanDate) -> JapanDate {
        model.today.isInSameMonth(as: month) ? model.today : month.firstOfMonth
    }

    // MARK: Geometry

    /// A month's height in List.
    private func height(of month: JapanDate) -> CGFloat {
        rowHeight * CGFloat(month.monthWeekLayout.count)
    }

    /// Where a month sits against the month on screen: the one before right
    /// above it, the one after right below.
    private func position(of month: JapanDate, from current: JapanDate) -> CGFloat {
        if month < current {
            -height(of: month)
        } else if month > current {
            height(of: current)
        } else {
            0
        }
    }

    /// The month area's height: the month on screen's, or the one it is
    /// settling to; its own once measured, and natural outside List.
    private func areaHeight(for month: JapanDate) -> CGFloat? {
        guard isList, rowHeight > 0 else { return nil }
        return settlingHeight ?? height(of: month)
    }

    // MARK: Dragging

    private var drag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                if isVerticalDrag == nil {
                    isVerticalDrag = abs(value.translation.height) > abs(value.translation.width)
                }
                guard isVerticalDrag == true, isSettling == false, reducesMotion == false else { return }
                dragOffset = value.translation.height
                show(
                    ScheduleMonthSwipe.preview(
                        translation: value.translation.height, height: height(of: model.displayedMonth)))
            }
            .onEnded { value in
                defer { isVerticalDrag = nil }
                guard isVerticalDrag == true, isSettling == false else { return }
                page(
                    ScheduleMonthSwipe.offset(
                        translation: value.translation.height,
                        predicted: value.predictedEndTranslation.height,
                        height: height(of: model.displayedMonth)),
                    velocity: value.velocity.height)
            }
    }

    /// Shows the month a release would land on in the header.
    private func show(_ direction: Int) {
        guard direction != preview else { return }
        withAnimation(ScheduleMonthSwipe.headerAnimation) { preview = direction }
    }

    /// Pages `direction` months from wherever a drag left the months, with
    /// the finger's `velocity` in points a second: they slide on with it to
    /// the month after or before, or back to rest, the area fitting the new
    /// month's weeks in the same spring. Reduce Motion cross-fades.
    private func page(_ direction: Int, velocity: CGFloat) {
        if reducesMotion {
            preview = 0
            guard direction != 0 else { return }
            withAnimation(ScheduleModeSwitch.crossFadeAnimation) { model.showMonth(offset: direction) }
            return
        }
        let month = model.displayedMonth
        let target = ScheduleMonthSwipe.settledOffset(
            direction: direction, height: height(of: month),
            previousHeight: height(of: month.addingMonths(-1)))
        let spring = ScheduleMonthSwipe.settleAnimation(
            from: dragOffset, to: target, velocity: velocity)
        show(direction)
        isSettling = true
        withAnimation(spring, completionCriteria: .logicallyComplete) {
            dragOffset = target
            settlingHeight = height(of: month.addingMonths(direction))
        } completion: {
            // The month it settled on is drawn exactly where its neighbour
            // was, so the swap shows no change.
            var swap = Transaction()
            swap.disablesAnimations = true
            withTransaction(swap) {
                if direction != 0 {
                    model.showMonth(offset: direction)
                }
                dragOffset = 0
                settlingHeight = nil
                preview = 0
            }
            isSettling = false
        }
    }
}
