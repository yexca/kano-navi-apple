import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The Schedule tab: the month in one of four modes under its name as the
/// large title, Today at the leading end, and the entry sheet. See
/// `docs/design.md`.
struct ScheduleScreen: View {
    @State private var model: ScheduleModel
    @State private var presented: PresentedEvent?
    /// Counts Today taps, so a grid scrolls to today's month even when that
    /// month is already the one named in the title.
    @State private var todayTaps = 0
    let feedURL: URL

    @Environment(AppRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @AppStorage(AppSettings.scheduleModeKey) private var mode = ScheduleMode.defaultMode

    init(loader: @escaping ScheduleModel.MonthLoader, feedURL: URL) {
        _model = State(initialValue: ScheduleModel(loader: loader))
        self.feedURL = feedURL
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(.Schedule.today, action: showToday)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ScheduleModeMenu(mode: $mode)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        ScheduleSubscriptionMenu(feedURL: feedURL)
                    }
                }
                // At accessibility sizes the month is abbreviated, so the year
                // stays in the title.
                .navigationTitle(
                    Text(
                        verbatim: model.displayedMonth.monthTitle(
                            locale: locale, abbreviated: dynamicTypeSize.isAccessibilitySize))
                )
                .navigationBarTitleDisplayMode(.large)
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

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .list:
            ScheduleListContent(model: model, contentLanguage: contentLanguage, open: open)
        case .compact, .stacked, .details:
            ScheduleGridContent(
                model: model, style: gridStyle, contentLanguage: contentLanguage, todayTaps: todayTaps,
                openDay: openDay)
        }
    }

    /// The grid's cells: at accessibility text sizes Stacked and Details
    /// fall back to Compact's dots, since titles and bars no longer fit.
    private var gridStyle: ScheduleMode {
        dynamicTypeSize.isAccessibilitySize ? .compact : mode
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
        mode = .list
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
