import Foundation

public struct WidgetCalendarResult: Equatable, Sendable {
    public var events: [ScheduleEvent]
    public var calendarEntries: [CalendarEntryView]
    public var nextTransitionAt: Date?
    public var fetchedAt: Date?
    public var isStale: Bool
    public init(events: [ScheduleEvent], calendarEntries: [CalendarEntryView], nextTransitionAt: Date?, fetchedAt: Date?, isStale: Bool) { self.events = events; self.calendarEntries = calendarEntries; self.nextTransitionAt = nextTransitionAt; self.fetchedAt = fetchedAt; self.isStale = isStale }
}

public struct ScheduleMonthResult: Equatable, Sendable {
    public var dates: [JapanDate]
    public var events: [ScheduleEvent]
    public var dayCounts: [JapanDate: Int]
    public var adjacent: ArchiveAdjacent
    public var isStale: Bool
    public init(dates: [JapanDate], events: [ScheduleEvent], dayCounts: [JapanDate: Int], adjacent: ArchiveAdjacent, isStale: Bool) { self.dates = dates; self.events = events; self.dayCounts = dayCounts; self.adjacent = adjacent; self.isStale = isStale }
}

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
                guard let value = await client.cached(CalendarRequest(from: from, to: to, page: page)) else { throw APIError.offline }
                result = value
            } else {
                result = try await client.send(CalendarRequest(from: from, to: to, page: page))
            }
            allEvents.append(contentsOf: result.events); allAssets.append(contentsOf: result.scheduleImages)
            for (day, count) in result.dayCounts { mergedCounts[day] = count }
            if !result.hasNext { return CalendarPage(events: allEvents, scheduleImages: allAssets, adjacent: result.adjacent, dayCounts: mergedCounts, total: result.total, page: result.page, pageSize: result.pageSize, totalPages: result.totalPages, hasNext: false, revision: result.revision) }
            page += 1
            if page > (result.totalPages ?? page) + 1 { throw APIError.decoding("Invalid calendar pagination") }
        }
    }

    public func widgetRange(today: JapanDate = .today, now: Date = Date()) async throws -> WidgetCalendarResult {
        do {
            let page = try await read(from: today, to: today.addingDays(13))
            let entries = page.events.flatMap { $0.view?.calendarEntries ?? [] }
            let transition = page.events.flatMap { event -> [Date] in
                let entryDates = (event.view?.calendarEntries ?? []).compactMap { entry in
                    entry.startsAt ?? JapanTime.calendar.date(from: DateComponents(year: entry.startsOn.year, month: entry.startsOn.month, day: entry.startsOn.day))
                }
                return [event.startsAt, event.endsAt, event.saleWindow?.startsAt, event.saleWindow?.endsAt].compactMap { $0 } + entryDates
            }.filter { $0 > now }.min()
            return WidgetCalendarResult(events: page.events, calendarEntries: entries, nextTransitionAt: transition, fetchedAt: Date(), isStale: false)
        } catch {
            if let page = await client.cached(CalendarRequest(from: today, to: today.addingDays(13))) {
                return WidgetCalendarResult(events: page.events, calendarEntries: page.events.flatMap { $0.view?.calendarEntries ?? [] }, nextTransitionAt: nil, fetchedAt: nil, isStale: true)
            }
            throw error
        }
    }

    public func readWidgetRange(today: JapanDate = .today, now: Date = Date()) async throws -> WidgetCalendarResult {
        try await widgetRange(today: today, now: now)
    }

    public func month(containing date: JapanDate) async throws -> ScheduleMonthResult {
        let dates = date.monthGrid
        let page = try await read(from: dates.first ?? date, to: dates.last ?? date)
        return ScheduleMonthResult(dates: dates, events: page.events, dayCounts: page.dayCounts, adjacent: page.adjacent, isStale: false)
    }

    public func readMonthGrid(containing date: JapanDate) async throws -> ScheduleMonthResult {
        try await month(containing: date)
    }
}
