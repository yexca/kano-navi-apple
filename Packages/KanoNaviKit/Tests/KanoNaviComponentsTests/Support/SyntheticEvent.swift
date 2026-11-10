import Foundation
import KanoNaviCore

/// Builds `ScheduleEvent` values from synthetic API JSON, the way the client
/// decodes them.
enum SyntheticEvent {
    static func make(
        id: String = "synthetic-1",
        title: String = "Synthetic stream",
        startsOn: String = "2026-11-12",
        startsAt: String? = "2026-11-12T12:00:00Z",
        timePrecision: String = "exact",
        typeCode: String = "stream",
        state: String = "upcoming",
        provenance: String = "automatic",
        manualLocked: Bool = false,
        sourceLanguage: String? = "ja",
        translations: [String: Any] = [:],
        calendarEntries: [[String: Any]]? = nil,
        includesView: Bool = true
    ) throws -> ScheduleEvent {
        var json: [String: Any] = [
            "id": id,
            "source": "youtube",
            "title": title,
            "startsOn": startsOn,
            "startsAt": startsAt as Any,
            "timezone": "Asia/Tokyo",
            "timePrecision": timePrecision,
            "eventType": typeCode,
            "provenance": provenance,
            "manualLocked": manualLocked,
            "cancellationStatus": "none",
            "platforms": ["youtube"],
            "sourceLanguage": sourceLanguage as Any,
            "translations": translations,
        ]
        if includesView {
            json["view"] = [
                "state": state,
                "typeCode": typeCode,
                "activityCode": "game",
                "activityContext": "stream",
                "isWork": false,
                "calendarEntries": calendarEntries ?? [
                    ["startsOn": startsOn, "startsAt": startsAt as Any, "timePrecision": timePrecision]
                ],
            ]
        }
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(ScheduleEvent.self, from: data)
    }
}
