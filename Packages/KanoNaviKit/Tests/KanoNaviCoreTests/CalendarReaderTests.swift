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
}
