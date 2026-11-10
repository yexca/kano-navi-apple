import Foundation
import KanoNaviCore

/// Synthetic schedule records, decoded the way the client decodes the API.
enum ScheduleFixtures {
    static let today = JapanDate(year: 2026, month: 11, day: 10)

    static func event(
        id: String,
        startsOn: String,
        startsAt: String? = nil,
        typeCode: String = "stream",
        calendarEntries: [[String: Any]]? = nil
    ) throws -> ScheduleEvent {
        let precision = startsAt == nil ? "date" : "exact"
        let json: [String: Any] = [
            "id": id,
            "source": "youtube",
            "title": id,
            "startsOn": startsOn,
            "startsAt": startsAt as Any,
            "timezone": "Asia/Tokyo",
            "timePrecision": precision,
            "eventType": typeCode,
            "provenance": "automatic",
            "cancellationStatus": "none",
            "url": "https://example.com/\(id)",
            "view": [
                "state": "upcoming",
                "typeCode": typeCode,
                "activityContext": "",
                "isWork": false,
                "calendarEntries": calendarEntries ?? [
                    ["startsOn": startsOn, "startsAt": startsAt as Any, "timePrecision": precision]
                ],
            ],
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(ScheduleEvent.self, from: data)
    }

    static func month(
        containing date: JapanDate, events: [ScheduleEvent], dayCounts: [JapanDate: Int] = [:],
        isStale: Bool = false
    ) -> ScheduleMonthResult {
        ScheduleMonthResult(
            dates: date.monthGrid, events: events, dayCounts: dayCounts, adjacent: ArchiveAdjacent(),
            isStale: isStale)
    }
}

/// Answers month loads from a queue of results per month. The last result
/// of a month repeats; a month without results is offline.
actor StubMonthLoader {
    private var responses: [JapanDate: [Result<ScheduleMonthResult, APIError>]]
    private(set) var requests: [JapanDate] = []

    init(_ responses: [JapanDate: [Result<ScheduleMonthResult, APIError>]]) {
        self.responses = responses
    }

    func load(_ month: JapanDate) throws -> ScheduleMonthResult {
        requests.append(month)
        guard var queue = responses[month], let next = queue.first else { throw APIError.offline }
        if queue.count > 1 {
            queue.removeFirst()
            responses[month] = queue
        }
        return try next.get()
    }
}

/// Holds loads until the test opens it, and counts how many entered.
actor LoadGate {
    private(set) var entries = 0
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func enter() async {
        entries += 1
        guard isOpen == false else { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func open() {
        isOpen = true
        for waiter in waiters {
            waiter.resume()
        }
        waiters.removeAll()
    }
}
