import Foundation
import KanoNaviCore

/// Synthetic dashboard and calendar responses for notification tests.
enum NotificationFixtures {
    static func calendarPageData(events: [[String: Any]] = []) throws -> Data {
        let object: [String: Any] = [
            "events": events,
            "scheduleImages": [],
            "adjacent": ["previous": NSNull(), "next": NSNull()],
            "dayCounts": [:],
            "total": events.count,
            "page": 1,
            "pageSize": 100,
            "totalPages": 1,
            "hasNext": false,
            "revision": 1,
        ]
        return try JSONSerialization.data(withJSONObject: object)
    }

    static func dashboardData(posts: [[String: Any]] = [], revision: Int) throws -> Data {
        let object: [String: Any] = [
            "profile": [
                "displayName": "Synthetic",
                "romanizedName": "Synthetic",
                "bio": "",
                "xUrl": "https://example.com/x",
                "youtubeUrl": "https://example.com/youtube",
            ],
            "projection": [
                "version": 1,
                "focus": ["eventIds": [], "videoIds": []],
                "spotlight": NSNull(),
                "sales": [],
                "shelf": [
                    "leadIsFeatured": false,
                    "reservations": [],
                    "works": [],
                    "archives": [],
                    "shorts": [],
                ],
            ],
            "summary": [:],
            "posts": posts,
            "events": [],
            "videos": [],
            "timeline": [],
            "resources": [],
            "assets": [],
            "scheduleImages": [],
            "meta": [
                "postWindowDays": 7,
                "xAccounts": ["kano_synthetic"],
                "revision": revision,
            ],
        ]
        return try JSONSerialization.data(withJSONObject: object)
    }

    static func dashboard(posts: [[String: Any]] = [], revision: Int) throws -> Dashboard {
        try JSONDecoder.kanoNavi().decode(
            Dashboard.self,
            from: dashboardData(posts: posts, revision: revision)
        )
    }

    /// An upcoming stream with an exact JST start time.
    static func streamJSON(id: String, startsAt: Date) -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let start = formatter.string(from: startsAt)
        let day = JapanDate.date(from: startsAt).description
        return [
            "id": id,
            "source": "youtube",
            "title": id,
            "startsOn": day,
            "startsAt": start,
            "endsAt": NSNull(),
            "timezone": "Asia/Tokyo",
            "timePrecision": "exact",
            "eventType": "stream",
            "provenance": "automatic",
            "cancellationStatus": "none",
            "url": "https://example.com/\(id)",
            "view": [
                "state": "upcoming",
                "typeCode": "stream",
                "activityContext": "",
                "isWork": false,
                "calendarEntries": [
                    ["startsOn": day, "startsAt": start, "timePrecision": "exact"]
                ],
            ],
        ]
    }

    /// A Kano X post published now.
    static func freshPostJSON(id: String) -> [String: Any] {
        [
            "id": id,
            "source": "x",
            "accountHandle": "kano_synthetic",
            "publishedAt": Date().ISO8601Format(),
            "text": "New announcement!",
            "url": "https://example.com/post/\(id)",
            "media": [],
            "mediaStatus": "none",
        ]
    }
}
