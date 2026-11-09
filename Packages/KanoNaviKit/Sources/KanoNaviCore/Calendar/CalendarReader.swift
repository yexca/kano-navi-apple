import Foundation

public struct CalendarReader: Sendable {
    public let client: APIClient
    public init(client: APIClient) { self.client = client }

    public func read(from: JapanDate, to: JapanDate) async throws -> CalendarPage {
        do {
            return try await readPages(from: from, to: to, cached: false)
        } catch {
            if let cached = try? await readPages(from: from, to: to, cached: true) { return cached }
            throw error
        }
    }

    private func readPages(from: JapanDate, to: JapanDate, cached: Bool) async throws -> CalendarPage {
        var page = 1
        var allEvents: [ScheduleEvent] = []
        var allAssets: [ScheduleAsset] = []
        var mergedCounts: [JapanDate: Int] = [:]
        while true {
            let result: CalendarPage
            if cached {
                guard let value = await client.cached(CalendarRequest(from: from, to: to, page: page))
                else { throw APIError.offline }
                result = value
            } else {
                result = try await client.send(CalendarRequest(from: from, to: to, page: page))
            }
            allEvents.append(contentsOf: result.events)
            allAssets.append(contentsOf: result.scheduleImages)
            for (day, count) in result.dayCounts { mergedCounts[day] = count }
            if !result.hasNext {
                return CalendarPage(
                    events: allEvents, scheduleImages: allAssets, adjacent: result.adjacent,
                    dayCounts: mergedCounts, total: result.total, page: result.page,
                    pageSize: result.pageSize, totalPages: result.totalPages, hasNext: false,
                    revision: result.revision)
            }
            page += 1
            if page > (result.totalPages ?? page) + 1 {
                throw APIError.decoding("Invalid calendar pagination")
            }
        }
    }

    public func widgetRange(today: JapanDate = .today, now: Date = Date()) async throws
        -> WidgetCalendarResult
    {
        do {
            let page = try await read(from: today, to: today.addingDays(13))
            let entries = page.events.flatMap { $0.view?.calendarEntries ?? [] }
            let transition = nextTransition(in: page, after: now)
            return WidgetCalendarResult(
                events: page.events, calendarEntries: entries, nextTransitionAt: transition,
                fetchedAt: Date(), isStale: false)
        } catch {
            if let page = await client.cached(CalendarRequest(from: today, to: today.addingDays(13))) {
                return WidgetCalendarResult(
                    events: page.events,
                    calendarEntries: page.events.flatMap { $0.view?.calendarEntries ?? [] },
                    nextTransitionAt: nextTransition(in: page, after: now), fetchedAt: nil, isStale: true)
            }
            throw error
        }
    }

    public func readWidgetRange(today: JapanDate = .today, now: Date = Date()) async throws
        -> WidgetCalendarResult
    {
        try await widgetRange(today: today, now: now)
    }

    public func month(containing date: JapanDate) async throws -> ScheduleMonthResult {
        let dates = date.monthGrid
        let page = try await read(from: dates.first ?? date, to: dates.last ?? date)
        return ScheduleMonthResult(
            dates: dates, events: page.events, dayCounts: page.dayCounts, adjacent: page.adjacent,
            isStale: false)
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
