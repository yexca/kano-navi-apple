import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Schedule tab: the month in one of four modes under its name as a
/// fixed header, Today at the leading end, and the entry sheet. See
/// `docs/architecture/board-and-timelines.md`.
struct ScheduleScreen: View {
    @State private var model: ScheduleModel
    @State private var presented: PresentedEvent?
    /// Counts Today taps, so a grid scrolls to today's month even when that
    /// month is already the one named in the title.
    @State private var todayTaps = 0
    /// The mode on screen, which follows `mode` through each switch's
    /// animation; `nil` until the first switch.
    @State private var shownMode: ScheduleMode?
    /// The grid mode List's month is drawn as while it turns into or out of
    /// that grid.
    @State private var expansion: ScheduleMode?
    /// The grid mode laid out, hidden, under List while List grows into it,
    /// so it has landed on the month when it takes over.
    @State private var pendingGrid: ScheduleMode?
    /// Counts requests for the grid to bring the month to the top before
    /// List takes over.
    @State private var alignRequests = 0
    /// The switch waiting for the grid to bring the month to the top: the
    /// grid mode it leaves and the mode it goes to.
    @State private var waitingSwitch: (from: ScheduleMode, to: ScheduleMode)?
    @State private var alignTask: Task<Void, Never>?
    /// Set by a deep link so its switch to List has no animation.
    @State private var switchesInstantly = false
    let feedURL: URL
    /// The dashboard's revision, which changes when the service's data does.
    let revision: Int?

    @Environment(AppRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @AppStorage(AppSettings.scheduleModeKey) private var mode = ScheduleMode.defaultMode

    init(loader: @escaping ScheduleModel.MonthLoader, feedURL: URL, revision: Int? = nil) {
        _model = State(initialValue: ScheduleModel(loader: loader))
        self.feedURL = feedURL
        self.revision = revision
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .barLeading) {
                        Button(.Schedule.today, action: showToday)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ScheduleModeMenu(mode: $mode)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ScheduleSubscriptionMenu(feedURL: feedURL)
                    }
                }
                // The month is drawn as a fixed header in the content, so it
                // never collapses with a scroll; the bar keeps the title only
                // for the app switcher and accessibility.
                .navigationTitle(Text(verbatim: model.displayedMonth.monthTitle(locale: locale)))
                .inlineNavigationTitle()
                .toolbar(removing: .title)
                .onAppear {
                    shownMode = shownMode ?? mode
                }
                .onChange(of: mode) { old, new in
                    switchMode(from: old, to: new)
                }
                // Months already read are read again when the service's data
                // changes or the app comes back, keeping them on screen.
                .onChange(of: revision) { old, _ in
                    guard old != nil else { return }
                    Task { await model.reloadAfterChange() }
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    Task { await model.reloadAfterChange() }
                }
                .task(id: model.displayedMonth) {
                    await model.loadMonths(around: model.displayedMonth)
                }
                .task(id: router.scheduleFocus) {
                    await consumeFocus()
                }
                .sheet(item: $presented) { presented in
                    ScheduleEventDetailView(event: presented.event)
                }
        }
    }

    /// The mode on screen.
    private var displayedMode: ScheduleMode {
        shownMode ?? mode
    }

    private var content: some View {
        let gridMode = displayedMode.isGrid ? displayedMode : pendingGrid
        return ZStack {
            if let gridMode {
                ScheduleGridContent(
                    model: model, style: gridStyle(gridMode), contentLanguage: contentLanguage,
                    todayTaps: todayTaps, alignRequests: alignRequests, onAligned: finishAligned,
                    openDay: openDay
                )
                .opacity(displayedMode.isGrid ? 1 : 0)
                .allowsHitTesting(displayedMode.isGrid)
                .transition(.opacity)
            }
            if displayedMode == .list {
                ScheduleListContent(
                    model: model, contentLanguage: contentLanguage, open: open,
                    expansion: expansion.map(gridStyle)
                )
                .transition(.opacity)
            }
        }
    }

    /// A grid mode's cells: at accessibility text sizes Stacked and Details
    /// fall back to Compact's dots, since titles and bars no longer fit.
    private func gridStyle(_ mode: ScheduleMode) -> ScheduleMode {
        dynamicTypeSize.isAccessibilitySize ? .compact : mode
    }

    /// Moves the screen from the mode on it to `new`; see
    /// ``ScheduleModeSwitch``.
    private func switchMode(from old: ScheduleMode, to new: ScheduleMode) {
        let isRunning = expansion != nil || pendingGrid != nil || waitingSwitch != nil
        let change = ScheduleModeSwitch.between(
            shownMode ?? old, new, reducesMotion: reducesMotion, isInstant: switchesInstantly || isRunning)
        switchesInstantly = false
        switch change {
        case .instant:
            settle(on: new)
        case .crossFade:
            withAnimation(ScheduleModeSwitch.crossFadeAnimation) { settle(on: new) }
        case .restyle:
            withAnimation(ScheduleModeSwitch.morphAnimation) {
                shownMode = new
            }
        case .expand(let grid):
            withAnimation(ScheduleModeSwitch.morphAnimation, completionCriteria: .logicallyComplete) {
                expansion = grid
            } completion: {
                guard mode == grid else { return }
                settle(on: grid)
            }
            Task {
                await Task.yield()
                guard mode == grid, expansion == grid else { return }
                pendingGrid = grid
            }
        case .collapse(let grid):
            waitForAlignment(from: grid, to: .list)
        }
    }

    /// Asks the grid to bring the month to the top, then goes on with the
    /// switch once it has, or after the time that takes at the latest.
    private func waitForAlignment(from grid: ScheduleMode, to target: ScheduleMode) {
        alignTask?.cancel()
        waitingSwitch = (grid, target)
        alignRequests += 1
        alignTask = Task {
            try? await Task.sleep(for: ScheduleModeSwitch.alignDuration)
            guard Task.isCancelled == false else { return }
            finishAligned()
        }
    }

    /// Hands a grid that has brought the month to the top over to List drawn
    /// exactly as the grid is, then shrinks its weeks into List's, fades out
    /// the next months and slides the day's entries up.
    private func finishAligned() {
        alignTask?.cancel()
        alignTask = nil
        guard let (grid, target) = waitingSwitch else { return }
        waitingSwitch = nil
        guard mode == target else { return }
        var swap = Transaction()
        swap.disablesAnimations = true
        withTransaction(swap) {
            expansion = grid
            pendingGrid = nil
            shownMode = .list
        }
        Task {
            await Task.yield()
            guard mode == target else { return }
            withAnimation(ScheduleModeSwitch.morphAnimation) { expansion = nil }
        }
    }

    private func settle(on mode: ScheduleMode) {
        alignTask?.cancel()
        alignTask = nil
        shownMode = mode
        expansion = nil
        pendingGrid = nil
        waitingSwitch = nil
    }

    private func showToday() {
        model.showToday()
        todayTaps += 1
    }

    private func open(_ event: ScheduleEvent) {
        presented = PresentedEvent(event: event)
    }

    private func openDay(_ date: JapanDate) {
        mode = model.openDay(date)
    }

    /// Applies a deep link's focus once in the List mode, then clears it.
    private func consumeFocus() async {
        guard let focus = router.scheduleFocus else { return }
        if mode != .list {
            switchesInstantly = true
            mode = .list
        }
        switch focus {
        case .date(let date):
            model.select(date)
        case .event(let id):
            let event = await model.focusEvent(id: id)
            guard Task.isCancelled == false else { return }
            presented = event.map(PresentedEvent.init)
        }
        if router.scheduleFocus == focus {
            router.scheduleFocus = nil
        }
    }
}
