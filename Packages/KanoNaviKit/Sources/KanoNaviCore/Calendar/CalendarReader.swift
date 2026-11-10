import Foundation

public struct CalendarReader: Sendable {
    public let client: APIClient
    public init(client: APIClient) { self.client = client }

    /// Reads every page of a range from the service, falling back to the
    /// cached pages when the service cannot be read. Use `readResult(from:to:)`
    /// to learn whether the fallback was used.
    public func read(from: JapanDate, to: JapanDate) async throws -> CalendarPage {
        try await readResult(from: from, to: to).page
    }

    /// Reads every page of a range from the service. When that fails and every
    /// page of the range is cached, returns the cached pages marked
    /// `isFromCache`; otherwise rethrows the service's error.
    public func readResult(from: JapanDate, to: JapanDate) async throws -> CalendarReadResult {
        do {
            let page = try await readPages(from: from, to: to)
            return CalendarReadResult(page: page, isFromCache: false, fetchedAt: Date())
        } catch {
            guard let cached = await readCachedPages(from: from, to: to) else { throw error }
            return CalendarReadResult(page: cached.page, isFromCache: true, fetchedAt: cached.fetchedAt)
        }
    }

    private func readPages(from: JapanDate, to: JapanDate) async throws -> CalendarPage {
        var merger = PageMerger()
        while true {
            let request = CalendarRequest(from: from, to: to, page: merger.nextPage)
            if let merged = try merger.add(try await client.send(request)) { return merged }
        }
    }

    /// The cached pages of a range and the oldest page's fetch time, or `nil`
    /// when any page is missing or unreadable.
    private func readCachedPages(from: JapanDate, to: JapanDate) async -> (
        page: CalendarPage, fetchedAt: Date
    )? {
        var merger = PageMerger()
        var oldest = Date.distantFuture
        while true {
            let request = CalendarRequest(from: from, to: to, page: merger.nextPage)
            guard let cached = await client.cachedValue(request) else { return nil }
            oldest = min(oldest, cached.fetchedAt)
            do {
                if let merged = try merger.add(cached.value) { return (merged, oldest) }
            } catch {
                return nil
            }
        }
    }

    public func widgetRange(today: JapanDate = .today, now: Date = Date()) async throws
        -> WidgetCalendarResult
    {
        let read = try await readResult(from: today, to: today.addingDays(13))
        return WidgetCalendarResult(
            events: read.page.events,
            calendarEntries: read.page.events.flatMap { $0.view?.calendarEntries ?? [] },
            nextTransitionAt: nextTransition(in: read.page, after: now), fetchedAt: read.fetchedAt,
            isStale: read.isFromCache)
    }

    public func readWidgetRange(today: JapanDate = .today, now: Date = Date()) async throws
        -> WidgetCalendarResult
    {
        try await widgetRange(today: today, now: now)
    }

    public func month(containing date: JapanDate) async throws -> ScheduleMonthResult {
        let dates = date.monthGrid
        let read = try await readResult(from: dates.first ?? date, to: dates.last ?? date)
        return ScheduleMonthResult(
            dates: dates, events: read.page.events, dayCounts: read.page.dayCounts,
            adjacent: read.page.adjacent, isStale: read.isFromCache, fetchedAt: read.fetchedAt)
    }

    public func readMonthGrid(containing date: JapanDate) async throws -> ScheduleMonthResult {
        try await month(containing: date)
    }

    private func nextTransition(in page: CalendarPage, after now: Date) -> Date? {
        page.events.flatMap { event -> [Date] in
            let entryDates = (event.view?.calendarEntries ?? []).flatMap { entry -> [Date] in
                guard entry.startsAt == nil else {
                    return [entry.startsAt].compactMap { $0 }
                }
                return [
                    JapanTime.startOfDay(entry.startsOn),
                    JapanTime.startOfDay(entry.startsOn.addingDays(1)),
                ].compactMap { $0 }
            }
            var dates = [event.startsAt, event.saleWindow?.startsAt, event.saleWindow?.endsAt]
                .compactMap { $0 }
            if event.liveStatus == .live {
                dates.append(contentsOf: [event.endsAt].compactMap { $0 })
            } else if let endsAt = event.endsAt {
                dates.append(endsAt)
            }
            return dates + entryDates
        }
        .filter { $0 > now }
        .min()
    }
}

/// Merges calendar pages in server order and checks their pagination.
private struct PageMerger {
    private(set) var nextPage = 1
    private var events: [ScheduleEvent] = []
    private var assets: [ScheduleAsset] = []
    private var dayCounts: [JapanDate: Int] = [:]

    /// Adds the page numbered `nextPage`. Returns the merged result after the
    /// last page, or `nil` when another page follows.
    mutating func add(_ page: CalendarPage) throws -> CalendarPage? {
        events.append(contentsOf: page.events)
        assets.append(contentsOf: page.scheduleImages)
        for (day, count) in page.dayCounts { dayCounts[day] = count }
        if !page.hasNext {
            return CalendarPage(
                events: events, scheduleImages: assets, adjacent: page.adjacent,
                dayCounts: dayCounts, total: page.total, page: page.page,
                pageSize: page.pageSize, totalPages: page.totalPages, hasNext: false,
                revision: page.revision)
        }
        nextPage += 1
        if nextPage > (page.totalPages ?? nextPage) + 1 {
            throw APIError.decoding("Invalid calendar pagination")
        }
        return nil
    }
}
