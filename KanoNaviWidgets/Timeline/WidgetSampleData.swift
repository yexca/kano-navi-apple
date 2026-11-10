import Foundation
import KanoNaviCore

/// A realistic week for the widget gallery and placeholders, built relative
/// to `now` without reading the network.
nonisolated enum WidgetSampleData {
    static func entry(now: Date, language: ContentLanguage) -> UpcomingEntry {
        UpcomingEntry(date: now, content: .schedule(schedule(now: now, language: language)))
    }

    static func schedule(now: Date, language: ContentLanguage) -> WidgetSchedule {
        let result = WidgetCalendarResult(
            events: events(now: now), calendarEntries: [], nextTransitionAt: nil, fetchedAt: now,
            isStale: false)
        return WidgetSchedule(result: result, language: language, interfaceLocale: .current)
    }

    static func events(now: Date) -> [ScheduleEvent] {
        let today = JapanDate.date(from: now)
        let liveStart = now.addingTimeInterval(-40 * 60)
        let tonight = at(today, hour: 21)
        let nextStream =
            tonight > now ? (today, tonight) : (today.addingDays(1), at(today.addingDays(1), hour: 21))
        let records: [[String: Any]] = [
            event(
                id: "sample-live", title: "朝の雑談配信", en: "Morning chat", zh: "早间杂谈",
                day: today, startsAt: liveStart, endsAt: liveStart.addingTimeInterval(2 * 60 * 60),
                state: "live", type: "stream"),
            event(
                id: "sample-sale", title: "誕生日グッズ販売", en: "Birthday merch sale", zh: "生日周边贩售",
                day: today.addingDays(-2), startsAt: at(today.addingDays(-2), hour: 12), state: "open",
                type: "sale",
                entries: [
                    (today.addingDays(-2), at(today.addingDays(-2), hour: 12), "opens"),
                    (today.addingDays(3), at(today.addingDays(3), hour: 23, minute: 59), "closes"),
                ]),
            event(
                id: "sample-game", title: "ホラーゲーム実況", en: "Horror game night", zh: "恐怖游戏实况",
                day: nextStream.0, startsAt: nextStream.1, state: "upcoming", type: "stream"),
            event(
                id: "sample-members", title: "メン限歌枠", en: "Members-only karaoke", zh: "会员限定歌回",
                day: today.addingDays(1), startsAt: at(today.addingDays(1), hour: 22), state: "upcoming",
                type: "member"),
            event(
                id: "sample-premiere", title: "歌ってみた プレミア公開", en: "Cover song premiere",
                zh: "翻唱首播", day: today.addingDays(2), startsAt: at(today.addingDays(2), hour: 18),
                state: "upcoming", type: "video"),
            event(
                id: "sample-collab", title: "コラボ配信", en: "Collab stream", zh: "联动直播",
                day: today.addingDays(4), startsAt: at(today.addingDays(4), hour: 21), state: "cancelled",
                type: "stream"),
            event(
                id: "sample-release", title: "ボイスパック発売", en: "Voice pack release", zh: "语音包发售",
                day: today.addingDays(5), startsAt: nil, state: "upcoming", type: "release"),
            event(
                id: "sample-chat", title: "深夜の雑談", en: "Late-night chat", zh: "深夜杂谈",
                day: today.addingDays(6), startsAt: at(today.addingDays(6), hour: 23), state: "upcoming",
                type: "stream"),
        ]
        return decode(records)
    }

    /// Decodes calendar records written as API JSON objects.
    static func decode(_ records: [[String: Any]]) -> [ScheduleEvent] {
        guard let data = try? JSONSerialization.data(withJSONObject: records),
            let events = try? JSONDecoder.kanoNavi().decode([ScheduleEvent].self, from: data)
        else {
            preconditionFailure("Widget sample data must decode as calendar events")
        }
        return events
    }

    // swift-format-ignore: FunctionParameterCount
    private static func event(
        id: String, title: String, en: String, zh: String, day: JapanDate, startsAt: Date?,
        endsAt: Date? = nil, state: String, type: String,
        entries: [(JapanDate, Date?, String?)]? = nil
    ) -> [String: Any] {
        let calendarEntries = (entries ?? [(day, startsAt, nil)]).map { entry in
            [
                "saleMark": entry.2 as Any,
                "startsOn": entry.0.rawValue,
                "startsAt": entry.1.map { $0.ISO8601Format() } as Any,
                "timePrecision": entry.1 == nil ? "date" : "exact",
            ]
        }
        return [
            "id": id,
            "source": "sample",
            "title": title,
            "sourceLanguage": "ja",
            "translations": [
                "en": ["text": en, "origin": "manual"],
                "zh-CN": ["text": zh, "origin": "manual"],
            ],
            "startsOn": day.rawValue,
            "startsAt": startsAt.map { $0.ISO8601Format() } as Any,
            "endsAt": endsAt.map { $0.ISO8601Format() } as Any,
            "timePrecision": startsAt == nil ? "date" : "exact",
            "eventType": type == "member" ? "member" : "stream",
            "provenance": "automatic",
            "cancellationStatus": state == "cancelled" ? "confirmed" : "none",
            "view": [
                "state": state,
                "typeCode": type,
                "activityContext": "",
                "isWork": false,
                "calendarEntries": calendarEntries,
            ],
        ]
    }

    private static func at(_ day: JapanDate, hour: Int, minute: Int = 0) -> Date {
        let start = JapanTime.startOfDay(day) ?? .now
        return start.addingTimeInterval(TimeInterval(hour * 60 * 60 + minute * 60))
    }
}
