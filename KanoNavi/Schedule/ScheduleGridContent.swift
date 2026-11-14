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
    /// The month a landing is bringing to the top, until it is there.
    @State private var landingMonth: JapanDate?
    /// Keeps `displayedMonth` locked while cell heights morph between
    /// `.compact` and taller grid styles.
    @State private var isRestyling = false
    @State private var restyleTask: Task<Void, Never>?

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
        ScrollViewReader { proxy in
            months
                .scrollPosition($position, anchor: .top)
                .task {
                    await land(on: model.displayedMonth, with: proxy)
                }
                // The month in view is the earliest one at least 40% on screen.
                .onScrollTargetVisibilityChange(idType: JapanDate.self, threshold: 0.4) { months in
                    guard let first = months.min() else { return }
                    // Until it has landed, the months the lazy stack passes on
                    // the way are not the month in view; it scrolls again
                    // until the month it lands on is at the top.
                    if let target = landingMonth {
                        if first == target {
                            if isRestyling == false {
                                landingMonth = nil
                                scrolledMonth = target
                                hasLanded = true
                            }
                        } else {
                            proxy.scrollTo(target, anchor: .top)
                        }
                        return
                    }
                    guard hasLanded else { return }
                    if first != scrolledMonth {
                        scrolledMonth = first
                        model.showMonth(first)
                    }
                }
                .onChange(of: style) { oldStyle, newStyle in
                    // Stacked and Details share the same fixed cell height, so
                    // switching between them never shifts the scroll position.
                    guard Self.rowHeightDiffers(between: oldStyle, and: newStyle) else { return }
                    restyleTask?.cancel()
                    let target = model.displayedMonth
                    isRestyling = true
                    landingMonth = target
                    proxy.scrollTo(target, anchor: .top)
                    restyleTask = Task {
                        try? await Task.sleep(for: .milliseconds(450))
                        guard Task.isCancelled == false else { return }
                        isRestyling = false
                        if landingMonth == target {
                            landingMonth = nil
                            scrolledMonth = target
                            hasLanded = true
                        }
                    }
                }
                .onChange(of: alignRequests) {
                    scrolledMonth = model.displayedMonth
                    withAnimation(ScheduleModeSwitch.alignAnimation, completionCriteria: .logicallyComplete) {
                        proxy.scrollTo(model.displayedMonth, anchor: .top)
                    } completion: {
                        onAligned()
                    }
                }
                .onChange(of: todayTaps) {
                    withAnimation {
                        proxy.scrollTo(model.today.firstOfMonth, anchor: .top)
                    }
                }
                .onChange(of: model.displayedMonth) { _, month in
                    if month != scrolledMonth {
                        withAnimation {
                            proxy.scrollTo(month, anchor: .top)
                        }
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

    private var months: some View {
        let today = model.today
        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.browsableMonths, id: \.self) { month in
                    ScheduleMonthView(
                        month: month, today: today, days: model.monthDays[month],
                        notice: model.notice(for: month), style: style, showsLabel: true, selectedDate: nil,
                        contentLanguage: contentLanguage, action: openDay, page: nil, retry: { retry(month) }
                    )
                    .equatable()
                    .id(month)
                }
            }
            .scrollTargetLayout()
        }
    }

    private func retry(_ month: JapanDate) {
        Task { await model.load(month) }
    }

    private static func rowHeightDiffers(between lhs: ScheduleMode, and rhs: ScheduleMode) -> Bool {
        (lhs == .compact) != (rhs == .compact)
    }

    /// Scrolls to a month's top on initial presentation. Since grid cells have
    /// deterministic heights, a brief pass settles the scroll position without
    /// blocking subsequent animations.
    private func land(on month: JapanDate, with proxy: ScrollViewProxy) async {
        hasLanded = false
        landingMonth = month
        for frame in 1...3 {
            guard landingMonth == month else { return }
            proxy.scrollTo(month, anchor: .top)
            try? await Task.sleep(for: .milliseconds(16 * frame))
        }
        guard landingMonth == month else { return }
        landingMonth = nil
        scrolledMonth = month
        hasLanded = true
    }
}
