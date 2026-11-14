import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Compact, Stacked and Details modes: months scrolling vertically one
/// after another under the pinned month name and weekday row. The month at
/// the top is the model's month, which names the header and is read with
/// the months beside it as it comes into view.
struct ScheduleGridContent: View {
    let model: ScheduleModel
    let style: ScheduleMode
    let contentLanguage: ContentLanguage
    /// Counts Today taps; each one scrolls to today's month.
    let todayTaps: Int
    /// Counts requests to bring the model's month to the top, made before
    /// the List mode takes its place.
    var alignRequests = 0
    /// Called once the model's month is at the top after a request.
    var onAligned: () -> Void = {}
    let openDay: (JapanDate) -> Void

    /// The month at the top of the scroll view, kept in step with the
    /// model's month.
    @State private var position: ScrollPosition
    /// The month scrolling last brought to the top, so that showing it does
    /// not scroll again.
    @State private var scrolledMonth: JapanDate?
    /// Whether the scroll view has landed on the month it opened on. Until
    /// then, the months it passes do not count as the month in view.
    @State private var hasLanded = false

    init(
        model: ScheduleModel, style: ScheduleMode, contentLanguage: ContentLanguage, todayTaps: Int,
        alignRequests: Int = 0, onAligned: @escaping () -> Void = {},
        openDay: @escaping (JapanDate) -> Void
    ) {
        self.model = model
        self.style = style
        self.contentLanguage = contentLanguage
        self.todayTaps = todayTaps
        self.alignRequests = alignRequests
        self.onAligned = onAligned
        self.openDay = openDay
        _position = State(initialValue: ScrollPosition(id: model.displayedMonth, anchor: .top))
    }

    var body: some View {
        let today = model.today
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.browsableMonths, id: \.self) { month in
                    ScheduleGridMonth(
                        month: month, today: today, days: model.monthDays[month],
                        notice: model.notice(for: month), style: style, contentLanguage: contentLanguage,
                        openDay: openDay, retry: { retry(month) }
                    )
                    .equatable()
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition($position, anchor: .top)
        .task {
            await land(on: model.displayedMonth)
        }
        // The month in view is the earliest one at least 40% on screen.
        .onScrollTargetVisibilityChange(idType: JapanDate.self, threshold: 0.4) { months in
            if hasLanded, let first = months.min(), first != scrolledMonth {
                scrolledMonth = first
                model.showMonth(first)
            }
        }
        .onChange(of: style) {
            // Cells change height with the style; keep the month in view.
            Task { await land(on: model.displayedMonth) }
        }
        .onChange(of: alignRequests) {
            scrolledMonth = model.displayedMonth
            withAnimation(ScheduleModeSwitch.alignAnimation, completionCriteria: .logicallyComplete) {
                position.scrollTo(id: model.displayedMonth, anchor: .top)
            } completion: {
                onAligned()
            }
        }
        .onChange(of: todayTaps) {
            withAnimation {
                position.scrollTo(id: model.today.firstOfMonth, anchor: .top)
            }
        }
        .onChange(of: model.displayedMonth) { _, month in
            if month != scrolledMonth {
                withAnimation {
                    position.scrollTo(id: month, anchor: .top)
                }
            }
        }
        // Applied before the pinned row, so the row's content does not pick
        // up its own refresh control.
        .refreshable {
            await model.refresh()
        }
        // The pinned header is opaque; the edge effect would draw the
        // scrolled months over it.
        .scrollEdgeEffectHidden(true, for: .top)
        .safeAreaBar(edge: .top) {
            VStack(spacing: 0) {
                ScheduleMonthHeader(month: model.displayedMonth)
                ScheduleWeekdayRow()
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .padding(.vertical, 6)
                ScheduleHairline()
            }
            .background(.background)
        }
    }

    private func retry(_ month: JapanDate) {
        Task { await model.load(month) }
    }

    /// Scrolls to a month's top. The lazy stack places months it has not
    /// measured by estimate, so the second pass, once the months around the
    /// target are laid out, lands exactly.
    private func land(on month: JapanDate) async {
        hasLanded = false
        for _ in 0..<2 {
            position.scrollTo(id: month, anchor: .top)
            await Task.yield()
        }
        scrolledMonth = month
        hasLanded = true
    }
}
