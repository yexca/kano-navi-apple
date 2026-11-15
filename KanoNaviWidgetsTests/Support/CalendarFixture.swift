import Foundation
import KanoNaviCore

/// Synthetic calendar records written as API JSON.
enum CalendarFixture {
    /// 2026-11-10 10:00 JST.
    static let now = date("2026-11-10T01:00:00Z")
    static let today = JapanDate(year: 2026, month: 11, day: 10)

    static func date(_ value: String) -> Date {
        guard let date = KanoNaviDateCoding.date(from: value) else {
            preconditionFailure("Invalid fixture timestamp \(value)")
        }
        return date
    }

    struct Entry {
        var day: String
        var startsAt: String?
        var saleMark: String?
    }

    // swift-format-ignore: FunctionParameterCount
    static func event(
        id: String, day: String, startsAt: String?, endsAt: String? = nil, state: String = "upcoming",
        typeCode: String = "stream", activityCode: String? = nil, title: String? = nil,
        sourceLanguage: String? = nil,
        translations: [String: String] = [:], entries: [Entry]? = nil
    ) -> [String: Any] {
        // As the service does, an activity label stands in for a plain
        // stream's type code.
        let viewTypeCode: String? = activityCode != nil && typeCode == "stream" ? nil : typeCode
        let calendarEntries = (entries ?? [Entry(day: day, startsAt: startsAt)]).map { entry in
            [
                "saleMark": entry.saleMark as Any,
                "startsOn": entry.day,
                "startsAt": entry.startsAt as Any,
                "timePrecision": entry.startsAt == nil ? "date" : "exact",
            ]
        }
        return [
            "id": id,
            "source": "synthetic",
            "title": title ?? id,
            "sourceLanguage": sourceLanguage as Any,
            "translations": translations.mapValues { ["text": $0, "origin": "manual"] },
            "startsOn": day,
            "startsAt": startsAt as Any,
            "endsAt": endsAt as Any,
            "timezone": "Asia/Tokyo",
            "timePrecision": startsAt == nil ? "date" : "exact",
            "eventType": typeCode,
            "provenance": "automatic",
            "cancellationStatus": "none",
            "view": [
                "state": state,
                "typeCode": viewTypeCode as Any,
                "activityCode": activityCode as Any,
                "activityContext": activityCode == nil ? "" : "stream",
                "isWork": false,
                "calendarEntries": calendarEntries,
            ],
        ]
    }

    static func events(_ records: [[String: Any]]) -> [ScheduleEvent] {
        WidgetSampleData.decode(records)
    }

    static func schedule(
        _ records: [[String: Any]], language: ContentLanguage = .en, nextTransitionAt: Date? = nil,
        isStale: Bool = false
    ) -> WidgetSchedule {
        let result = WidgetCalendarResult(
            events: events(records), calendarEntries: [], nextTransitionAt: nextTransitionAt,
            fetchedAt: now, isStale: isStale)
        return WidgetSchedule(
            result: result, language: language, interfaceLocale: Locale(identifier: "en_US"))
    }

    /// One complete calendar page as the API serves it.
    static func page(_ records: [[String: Any]]) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "events": records,
            "scheduleImages": [],
            "adjacent": ["previous": NSNull(), "next": NSNull()],
            "dayCounts": [:],
            "total": records.count,
            "page": 1,
            "pageSize": 100,
            "totalPages": 1,
            "hasNext": false,
            "revision": 1,
        ])
    }
}
