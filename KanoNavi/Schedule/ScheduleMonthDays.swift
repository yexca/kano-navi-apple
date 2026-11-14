import KanoNaviCore

/// A loaded month's entries by day, built once from its events so a
/// calendar cell never filters the month's events itself. A new value is
/// made for each read, so views compare it by identity.
nonisolated final class ScheduleMonthDays: Sendable {
    /// The month's first day.
    let month: JapanDate
    private let days: [JapanDate: [ScheduleDayEntry]]

    init(month: JapanDate, events: [ScheduleEvent]) {
        self.month = month
        days = ScheduleDayEntry.index(of: events, in: month)
    }

    /// The entries on a day of this month, sorted for display.
    func entries(on date: JapanDate) -> [ScheduleDayEntry] {
        days[date] ?? []
    }
}
