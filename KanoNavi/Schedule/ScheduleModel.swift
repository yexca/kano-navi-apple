import Foundation
import KanoNaviComponents
import KanoNaviCore
import Observation

/// The Schedule tab's state: the month on screen, the selected Japan date and
/// the loaded months.
///
/// A failed load keeps the month's last good result and records the failure
/// beside it, so the screen shows both.
@Observable
final class ScheduleModel {
    /// Reads the six-week grid of the month containing a date, usually
    /// `CalendarReader.month(containing:)`.
    typealias MonthLoader = @Sendable (JapanDate) async throws -> ScheduleMonthResult

    /// The first day of the month on screen.
    private(set) var displayedMonth: JapanDate
    /// The day whose entries are listed.
    private(set) var selectedDate: JapanDate
    /// Loaded months by their first day.
    private(set) var months: [JapanDate: ScheduleMonthResult] = [:]
    /// The last failure per month, cleared by a successful load.
    private(set) var failures: [JapanDate: any Error] = [:]
    private(set) var loadingMonths: Set<JapanDate> = []
    @ObservationIgnored private var inFlight: [JapanDate: Task<Void, Never>] = [:]

    private let loader: MonthLoader
    private let todayProvider: () -> JapanDate

    init(loader: @escaping MonthLoader, today: @escaping () -> JapanDate = { .today }) {
        self.loader = loader
        self.todayProvider = today
        let today = today()
        displayedMonth = today.firstOfMonth
        selectedDate = today
    }

    /// Today's Japan date.
    var today: JapanDate { todayProvider() }

    /// The loaded result for the month on screen.
    var month: ScheduleMonthResult? { months[displayedMonth] }

    /// The 42 Monday-first dates on screen. They are known before the month
    /// loads, so the grid never blanks.
    var gridDates: [JapanDate] { month?.dates ?? displayedMonth.monthGrid }

    /// Whether the month on screen is loading.
    var isLoading: Bool { loadingMonths.contains(displayedMonth) }

    /// The last failure loading the month on screen.
    var failure: (any Error)? { failures[displayedMonth] }

    /// Why the month on screen is not a fresh read, or `nil` when it is.
    var notice: ScheduleNotice? {
        if failure != nil {
            return month == nil ? .loadFailed : .updateFailed
        }
        guard let month, month.isStale else { return nil }
        return .saved(fetchedAt: month.fetchedAt)
    }

    /// The number of entries the server counts on a date.
    func count(on date: JapanDate) -> Int {
        result(containing: date)?.dayCounts[date] ?? 0
    }

    /// The entries on a date, from the loaded month whose grid contains it.
    func entries(on date: JapanDate) -> [ScheduleDayEntry] {
        guard let result = result(containing: date) else { return [] }
        return ScheduleDayEntry.entries(on: date, in: result.events)
    }

    /// Selects a date. A date outside the grid on screen also shows its month.
    func select(_ date: JapanDate) {
        if gridDates.contains(date) == false {
            displayedMonth = date.firstOfMonth
        }
        selectedDate = date
    }

    /// Shows the month `offset` months away and selects today in it, or its
    /// first day.
    func showMonth(offset: Int) {
        let target = displayedMonth.addingMonths(offset)
        displayedMonth = target
        selectedDate = today.isInSameMonth(as: target) ? today : target
    }

    /// Loads the month on screen unless it is loaded already.
    func loadIfNeeded() async {
        guard months[displayedMonth] == nil else { return }
        await load(displayedMonth)
    }

    /// Reloads the month on screen, for pull to refresh and retry.
    func refresh() async {
        await load(displayedMonth)
    }

    /// Loads a month by its first day. A load that starts while another of
    /// the same month runs waits for that request instead of sending its own,
    /// so every caller sees the result when it returns.
    func load(_ month: JapanDate) async {
        if let running = inFlight[month] {
            await running.value
            return
        }
        let request = Task { await perform(month) }
        inFlight[month] = request
        loadingMonths.insert(month)
        await request.value
        inFlight[month] = nil
        loadingMonths.remove(month)
    }

    private func perform(_ month: JapanDate) async {
        do {
            let result = try await loader(month)
            months[month] = result
            failures[month] = nil
        } catch is CancellationError {
            return
        } catch APIError.cancelled {
            return
        } catch {
            failures[month] = error
        }
    }

    /// Finds an event for a deep link: in the loaded months, then in the
    /// month on screen and the month after it, then in this month and the
    /// next. Selects the event's first calendar day and returns the event.
    func focusEvent(id: String) async -> ScheduleEvent? {
        if let event = loadedEvent(id: id) {
            select(Self.calendarDay(of: event))
            return event
        }
        let candidates = [
            displayedMonth, displayedMonth.addingMonths(1), today.firstOfMonth,
            today.firstOfMonth.addingMonths(1),
        ]
        for month in candidates where months[month] == nil {
            await load(month)
            if Task.isCancelled { return nil }
            if let event = loadedEvent(id: id) {
                select(Self.calendarDay(of: event))
                return event
            }
        }
        return nil
    }

    private func loadedEvent(id: String) -> ScheduleEvent? {
        let ordered = [displayedMonth] + months.keys.sorted().filter { $0 != displayedMonth }
        for month in ordered {
            if let event = months[month]?.events.first(where: { $0.id == id }) {
                return event
            }
        }
        return nil
    }

    private func result(containing date: JapanDate) -> ScheduleMonthResult? {
        if let month, month.dates.contains(date) {
            return month
        }
        return months[date.firstOfMonth]
    }

    /// The day an event is shown on when it is opened from a link: its first
    /// calendar entry, which is a sale's opening.
    static func calendarDay(of event: ScheduleEvent) -> JapanDate {
        event.displayCalendarEntries.first?.startsOn ?? event.startsOn
    }
}
