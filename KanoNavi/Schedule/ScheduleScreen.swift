import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// The month calendar, the selected day's entries and the entry sheet.
struct ScheduleScreen: View {
    @State private var model: ScheduleModel
    @State private var presented: PresentedEvent?
    let feedURL: URL

    @Environment(AppRouter.self) private var router
    @Environment(\.locale) private var locale
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system

    init(loader: @escaping ScheduleModel.MonthLoader, feedURL: URL) {
        _model = State(initialValue: ScheduleModel(loader: loader))
        self.feedURL = feedURL
    }

    var body: some View {
        NavigationStack {
            List {
                if let notice {
                    Section {
                        ScheduleStatusNotice(kind: notice) {
                            Task { await model.refresh() }
                        }
                    }
                }
                Section {
                    ScheduleMonthCalendar(model: model)
                        .listRowInsets(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
                }
                Section {
                    dayEntries
                } header: {
                    Text(verbatim: model.selectedDate.dayTitle(locale: locale))
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await model.refresh()
            }
            .navigationTitle(.tabSchedule)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(.Schedule.today) {
                        model.select(model.today)
                    }
                    .disabled(
                        model.selectedDate == model.today && model.displayedMonth == model.today.firstOfMonth)
                }
                ToolbarItem(placement: .primaryAction) {
                    ScheduleSubscriptionMenu(feedURL: feedURL)
                }
            }
            .task(id: model.displayedMonth) {
                await model.loadIfNeeded()
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
    private var dayEntries: some View {
        let entries = model.entries(on: model.selectedDate)
        if entries.isEmpty == false {
            ForEach(entries) { item in
                Button {
                    presented = PresentedEvent(event: item.event)
                } label: {
                    EventRow(event: item.event, entry: item.entry, contentLanguage: contentLanguage)
                }
                .tint(.primary)
            }
        } else if model.month == nil, model.isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text(.Schedule.loading)
                    .foregroundStyle(.secondary)
            }
        } else if model.month != nil {
            Text(.Schedule.noEntries)
                .foregroundStyle(.secondary)
        }
    }

    private var notice: ScheduleStatusNotice.Kind? {
        if model.failure != nil {
            return model.month == nil ? .loadFailed : .updateFailed
        }
        return model.month?.isStale == true ? .stale : nil
    }

    /// Applies a deep link's focus once, then clears it.
    private func consumeFocus() async {
        guard let focus = router.scheduleFocus else { return }
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
