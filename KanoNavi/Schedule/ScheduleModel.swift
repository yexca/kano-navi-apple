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
    private(set) var displayedMonth: JapanDate {
        didSet {
            if displayedMonth < browsableMonths.first ?? displayedMonth
                || displayedMonth > browsableMonths.last ?? displayedMonth
            {
                browsableMonths = Self.browsableMonths(today: today, reaching: displayedMonth)
            }
        }
    }
    /// The day whose entries are listed.
    private(set) var selectedDate: JapanDate
    /// Loaded months by their first day.
    private(set) var months: [JapanDate: ScheduleMonthResult] = [:]
    /// Loaded months that may be out of date since the service changed. They
    /// stay on screen and are read again when shown.
    private(set) var staleMonths: Set<JapanDate> = []
    /// Loaded months' entries by day, by the month's first day.
    private(set) var monthDays: [JapanDate: ScheduleMonthDays] = [:]
    /// The months the screen can show, by their first day: five years back
    /// and two years ahead of today, widened to reach the month on screen.
    private(set) var browsableMonths: [JapanDate]
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
        browsableMonths = Self.browsableMonths(today: today, reaching: today)
    }

    /// Today's Japan date.
    var today: JapanDate { todayProvider() }

    /// The loaded result for the month on screen.
    var month: ScheduleMonthResult? { months[displayedMonth] }

    /// Whether the month on screen is loading.
    var isLoading: Bool { loadingMonths.contains(displayedMonth) }

    /// The last failure loading the month on screen.
    var failure: (any Error)? { failures[displayedMonth] }

    /// Why the month on screen is not a fresh read, or `nil` when it is.
    var notice: ScheduleNotice? { notice(for: displayedMonth) }

    /// Why a month is not a fresh read, or `nil` when it is or has not been
    /// read yet.
    func notice(for month: JapanDate) -> ScheduleNotice? {
        let result = months[month]
        if failures[month] != nil {
            return result == nil ? .loadFailed : .updateFailed
        }
        guard let result, result.isStale else { return nil }
        return .saved(fetchedAt: result.fetchedAt)
    }

    private static let monthsBack = 60
    private static let monthsAhead = 24

    private static func browsableMonths(today: JapanDate, reaching month: JapanDate) -> [JapanDate] {
        let current = today.firstOfMonth
        let first = min(current.addingMonths(-monthsBack), month.firstOfMonth)
        let last = max(current.addingMonths(monthsAhead), month.firstOfMonth)
        var months: [JapanDate] = []
        var next = first
        while next <= last {
            months.append(next)
            next = next.addingMonths(1)
        }
        return months
    }

    /// The entries on a date, from its month's index once that month loads.
    func entries(on date: JapanDate) -> [ScheduleDayEntry] {
        monthDays[date.firstOfMonth]?.entries(on: date) ?? []
    }

    /// Selects a date and shows its month, since a month shows only its own
    /// days.
    func select(_ date: JapanDate) {
        displayedMonth = date.firstOfMonth
        selectedDate = date
    }

    /// Shows the month `offset` months away and selects today in it, or its
    /// first day. Swiping the List mode's month and its VoiceOver actions
    /// page this way.
    func showMonth(offset: Int) {
        showMonth(displayedMonth.addingMonths(offset))
    }

    /// Shows the month of `month` and selects today in it, or its first day.
    /// The month already on screen keeps its selection.
    func showMonth(_ month: JapanDate) {
        let target = month.firstOfMonth
        guard target != displayedMonth else { return }
        displayedMonth = target
        selectedDate = today.isInSameMonth(as: target) ? today : target
    }

    /// Shows today's month with today selected, for the month title.
    func showToday() {
        displayedMonth = today.firstOfMonth
        selectedDate = today
        browsableMonths = Self.browsableMonths(today: today, reaching: today)
    }

    /// Opens a day tapped in a grid mode: its month with the day selected,
    /// in the mode that lists the day's entries.
    func openDay(_ date: JapanDate) -> ScheduleMode {
        displayedMonth = date.firstOfMonth
        selectedDate = date
        return .list
    }

    /// The months to read when `month` is in view: it first, then the month
    /// after it and the month before it, leaving out those loaded and current
    /// or loading.
    func monthsToLoad(around month: JapanDate) -> [JapanDate] {
        let center = month.firstOfMonth
        return [center, center.addingMonths(1), center.addingMonths(-1)].filter {
            (months[$0] == nil || staleMonths.contains($0)) && inFlight[$0] == nil
        }
    }

    /// Marks every loaded month out of date after the service changed or the
    /// app came back, then reads the month on screen and the months beside it
    /// again; the others are read again when shown. What is on screen, the
    /// selection and the scroll position stay until each read returns.
    func reloadAfterChange() async {
        staleMonths = Set(months.keys)
        await loadMonths(around: displayedMonth)
    }

    /// Reads the months around `month` that are not loaded yet, or out of
    /// date, together.
    func loadMonths(around month: JapanDate) async {
        await withTaskGroup(of: Void.self) { group in
            for month in monthsToLoad(around: month) {
                group.addTask { await self.load(month) }
            }
        }
    }

    /// Loads the month on screen unless it is loaded already.
    func loadIfNeeded() async {
        guard months[displayedMonth] == nil || staleMonths.contains(displayedMonth) else { return }
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
            monthDays[month] = ScheduleMonthDays(month: month, events: result.events)
            staleMonths.remove(month)
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

    /// The day an event is shown on when it is opened from a link: its first
    /// calendar entry, which is a sale's opening.
    static func calendarDay(of event: ScheduleEvent) -> JapanDate {
        event.displayCalendarEntries.first?.startsOn ?? event.startsOn
    }
}
