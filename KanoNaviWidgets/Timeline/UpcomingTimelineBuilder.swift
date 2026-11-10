import Foundation

/// Turns one calendar read into timeline entries and a reload date.
nonisolated enum UpcomingTimelineBuilder {
    /// The longest a timeline waits before asking the service again.
    static let refreshInterval: TimeInterval = 30 * 60
    /// How soon to retry when nothing could be read or cached.
    static let retryInterval: TimeInterval = 15 * 60
    /// The most entries one timeline holds.
    static let maximumEntries = 48

    /// Entries now and at each later start, end, sale opening or closing and
    /// change of day; the reload date is the service's next transition or
    /// ``refreshInterval`` from now, whichever is sooner.
    static func timeline(for content: UpcomingContent, now: Date) -> (
        entries: [UpcomingEntry], reloadDate: Date
    ) {
        guard case .schedule(let schedule) = content else {
            return ([UpcomingEntry(date: now, content: content)], now.addingTimeInterval(retryInterval))
        }
        let dates = [now] + schedule.transitionDates(after: now).prefix(maximumEntries - 1)
        let entries = dates.map { UpcomingEntry(date: $0, content: content) }
        return (entries, reloadDate(for: schedule, now: now))
    }

    static func reloadDate(for schedule: WidgetSchedule, now: Date) -> Date {
        let latest = now.addingTimeInterval(refreshInterval)
        guard let next = schedule.nextTransitionAt, next > now else { return latest }
        return min(next, latest)
    }
}
