import Foundation
import Testing

@testable import KanoNaviCore

struct CalendarReaderTests {
    private func date(_ value: String) throws -> Date {
        try #require(KanoNaviDateCoding.date(from: value))
    }

    private func event(id: String, day: String, startsAt: String?, endsAt: String? = nil) -> [String:
        Any]
    {
        [
            "id": id,
            "source": "synthetic",
            "title": id,
            "startsOn": day,
            "startsAt": startsAt as Any,
            "endsAt": endsAt as Any,
            "timezone": "Asia/Tokyo",
            "timePrecision": startsAt == nil ? "date" : "exact",
            "eventType": "stream",
            "provenance": "automatic",
            "cancellationStatus": "none",
            "view": [
                "state": "upcoming",
                "typeCode": "stream",
                "activityCode": "live",
                "activityContext": "stream",
                "isWork": false,
                "calendarEntries": [
                    [
                        "saleMark": NSNull(),
                        "startsOn": day,
                        "startsAt": startsAt as Any,
                        "timePrecision": startsAt == nil ? "date" : "exact",
                    ]
                ],
            ],
        ]
    }

    private func page(events: [[String: Any]], page: Int, hasNext: Bool) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "events": events,
            "scheduleImages": [],
            "adjacent": ["previous": NSNull(), "next": NSNull()],
            "dayCounts": ["2026-11-10": events.count],
            "total": events.count,
            "page": page,
            "pageSize": 1,
            "totalPages": hasNext ? 2 : 1,
            "hasNext": hasNext,
            "revision": 1,
        ])
    }

    @Test func mergesCalendarPagesInServerOrder() async throws {
        let first = try page(
            events: [event(id: "first", day: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")],
            page: 1,
            hasNext: true
        )
        let second = try page(
            events: [event(id: "second", day: "2026-11-11", startsAt: "2026-11-11T01:00:00Z")],
            page: 2,
            hasNext: false
        )
        let transport = SequenceTransport([
            .success(TransportResponse(data: first, statusCode: 200)),
            .success(TransportResponse(data: second, statusCode: 200)),
        ])
        let api = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
        let from = try #require(JapanDate(rawValue: "2026-11-10"))
        let result = try await CalendarReader(client: api).read(from: from, to: from.addingDays(1))
        #expect(result.events.map(\.id) == ["first", "second"])
    }

    @Test func widgetIncludesDateBoundariesAndLiveEnd() async throws {
        let body = try page(
            events: [
                event(id: "date", day: "2026-11-10", startsAt: nil),
                event(
                    id: "live",
                    day: "2026-11-10",
                    startsAt: "2026-11-10T00:00:00Z",
                    endsAt: "2026-11-10T02:00:00Z"
                ),
            ], page: 1, hasNext: false)
        let api = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: FixtureTransport(response: TransportResponse(data: body, statusCode: 200)),
            cache: MemoryResponseCache()
        )
        let reader = CalendarReader(client: api)
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let beforeEnd = try date("2026-11-10T01:00:00Z")
        let expectedEnd = try date("2026-11-10T02:00:00Z")
        let first = try await reader.widgetRange(today: today, now: beforeEnd)
        #expect(first.nextTransitionAt == expectedEnd)

        let afterEnd = try date("2026-11-10T03:00:00Z")
        let expectedNextDay = try date("2026-11-10T15:00:00Z")
        let second = try await reader.widgetRange(today: today, now: afterEnd)
        #expect(second.nextTransitionAt == expectedNextDay)
    }

    // MARK: - Where the data came from

    private let baseURL = "https://api.example.com"

    private func client(_ transport: any APITransport, cache: any ResponseCache) throws -> APIClient {
        try APIClient(baseURL: try #require(URL(string: baseURL)), transport: transport, cache: cache)
    }

    /// Caches a two-page range as an earlier read would have: page 1 fetched
    /// at `newer`, page 2 at `older`.
    private func seedTwoPages(
        _ cache: MemoryResponseCache, from: JapanDate, to: JapanDate, newer: Date, older: Date
    ) async throws {
        let bodies = [
            try page(
                events: [event(id: "first", day: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")],
                page: 1, hasNext: true),
            try page(
                events: [event(id: "second", day: "2026-11-11", startsAt: "2026-11-11T01:00:00Z")],
                page: 2, hasNext: false),
        ]
        for (index, (body, fetchedAt)) in zip(bodies, [newer, older]).enumerated() {
            let key =
                "\(baseURL)/api/calendar?from=\(from.rawValue)&to=\(to.rawValue)&page=\(index + 1)&pageSize=100"
            await cache.save(CachedResponse(body: body, etag: nil, fetchedAt: fetchedAt), key: key)
        }
    }

    @Test func freshMonthIsNotStale() async throws {
        let body = try page(
            events: [event(id: "fresh", day: "2026-11-10", startsAt: nil)], page: 1, hasNext: false)
        let reader = CalendarReader(
            client: try client(
                FixtureTransport(response: TransportResponse(data: body, statusCode: 200)),
                cache: MemoryResponseCache()))
        let november = try #require(JapanDate(rawValue: "2026-11-10"))
        let startedAt = Date()

        let month = try await reader.month(containing: november)

        #expect(month.isStale == false)
        #expect(month.events.map(\.id) == ["fresh"])
        let fetchedAt = try #require(month.fetchedAt)
        #expect(fetchedAt >= startedAt)
        #expect(fetchedAt <= Date())
    }

    @Test func freshWidgetRangeIsNotStale() async throws {
        let body = try page(
            events: [event(id: "fresh", day: "2026-11-10", startsAt: nil)], page: 1, hasNext: false)
        let reader = CalendarReader(
            client: try client(
                FixtureTransport(response: TransportResponse(data: body, statusCode: 200)),
                cache: MemoryResponseCache()))
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let startedAt = Date()

        let range = try await reader.widgetRange(today: today, now: try date("2026-11-09T00:00:00Z"))

        #expect(range.isStale == false)
        let fetchedAt = try #require(range.fetchedAt)
        #expect(fetchedAt >= startedAt)
        #expect(fetchedAt <= Date())
    }

    @Test func failedMonthReadFallsBackToTheCacheMarkedStale() async throws {
        let november = try #require(JapanDate(rawValue: "2026-11-10"))
        let grid = november.monthGrid
        let from = try #require(grid.first)
        let to = try #require(grid.last)
        let newer = try date("2026-11-09T12:00:00Z")
        let older = try date("2026-11-09T11:59:00Z")
        let cache = MemoryResponseCache()
        try await seedTwoPages(cache, from: from, to: to, newer: newer, older: older)
        let reader = CalendarReader(client: try client(SequenceTransport([]), cache: cache))

        let month = try await reader.month(containing: november)

        #expect(month.isStale)
        #expect(month.fetchedAt == older)
        #expect(month.events.map(\.id) == ["first", "second"])
    }

    @Test func failedWidgetReadFallsBackToTheCacheMarkedStale() async throws {
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let newer = try date("2026-11-09T12:00:00Z")
        let older = try date("2026-11-09T11:59:00Z")
        let cache = MemoryResponseCache()
        try await seedTwoPages(cache, from: today, to: today.addingDays(13), newer: newer, older: older)
        let reader = CalendarReader(client: try client(SequenceTransport([]), cache: cache))

        let range = try await reader.widgetRange(today: today, now: try date("2026-11-09T00:00:00Z"))

        #expect(range.isStale)
        #expect(range.fetchedAt == older)
        #expect(range.events.map(\.id) == ["first", "second"])
    }

    @Test func readKeepsReturningCachedPagesWhenOffline() async throws {
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let to = today.addingDays(13)
        let cache = MemoryResponseCache()
        let fetchedAt = try date("2026-11-09T12:00:00Z")
        try await seedTwoPages(cache, from: today, to: to, newer: fetchedAt, older: fetchedAt)
        let reader = CalendarReader(client: try client(SequenceTransport([]), cache: cache))

        let page = try await reader.read(from: today, to: to)
        let result = try await reader.readResult(from: today, to: to)

        #expect(page.events.map(\.id) == ["first", "second"])
        #expect(result == CalendarReadResult(page: page, isFromCache: true, fetchedAt: fetchedAt))
    }

    @Test func failedReadWithoutCacheThrows() async throws {
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let reader = CalendarReader(
            client: try client(SequenceTransport([]), cache: MemoryResponseCache()))

        await #expect(throws: APIError.offline) {
            try await reader.month(containing: today)
        }
        await #expect(throws: APIError.offline) {
            try await reader.widgetRange(today: today)
        }
    }

    @Test func failedReadWithAMissingCachedPageThrows() async throws {
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let to = today.addingDays(13)
        let cache = MemoryResponseCache()
        let fetchedAt = try date("2026-11-09T12:00:00Z")
        try await seedTwoPages(cache, from: today, to: to, newer: fetchedAt, older: fetchedAt)
        await cache.remove(
            key: "\(baseURL)/api/calendar?from=\(today.rawValue)&to=\(to.rawValue)&page=2&pageSize=100")
        let reader = CalendarReader(client: try client(SequenceTransport([]), cache: cache))

        await #expect(throws: APIError.offline) {
            try await reader.widgetRange(today: today)
        }
    }
}
