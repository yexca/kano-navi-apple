import Foundation
import KanoNaviCore

/// Builds synthetic dashboard snapshots for the Now tests. Records use
/// reserved `example.com` URLs and are decoded with the API's own decoder, so
/// they follow the public JSON shape.
struct DashboardFixture {
    var events: [[String: Any]] = []
    var videos: [[String: Any]] = []
    var spotlight: [String: Any]?
    var sales: [String] = []
    var liveNow: [String: Any]?
    var latestVideo: [String: Any]?
    var nextEvent: [String: Any]?
    var lastSync: [String: Any]?
    var sourceFetchedAt: [String: Any]?
    /// The projection's shelf; an empty shelf when `nil`.
    var shelf: [String: Any]?
    var posts: [[String: Any]] = []
    var xAccounts = ["synthetic"]
    var bilibiliAccounts: [String]?

    func dashboard() throws -> Dashboard {
        var summary: [String: Any] = [:]
        summary["latestVideo"] = latestVideo
        summary["nextEvent"] = nextEvent
        var meta: [String: Any] = ["postWindowDays": 7, "xAccounts": xAccounts]
        meta["bilibiliAccounts"] = bilibiliAccounts
        meta["lastSync"] = lastSync
        meta["sourceFetchedAt"] = sourceFetchedAt
        var body: [String: Any] = [
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
                "spotlight": spotlight.map { $0 as Any } ?? NSNull(),
                "sales": sales,
                "shelf": shelf ?? [
                    "leadIsFeatured": false, "reservations": [], "works": [], "archives": [], "shorts": [],
                ],
            ],
            "summary": summary,
            "posts": posts,
            "events": events,
            "videos": videos,
            "timeline": [],
            "resources": [],
            "assets": [],
            "scheduleImages": [],
            "meta": meta,
        ]
        body["liveNow"] = liveNow
        let data = try JSONSerialization.data(withJSONObject: body)
        return try JSONDecoder.kanoNavi().decode(Dashboard.self, from: data)
    }

    static func spotlight(
        mode: String = "next", eventID: String? = nil, videoID: String? = nil, liveNow: Bool = false,
        isLive: Bool = false, membersChip: Bool = false, companionVideoID: String? = nil
    ) -> [String: Any] {
        [
            "mode": mode,
            "eventId": eventID ?? NSNull(),
            "videoId": videoID ?? NSNull(),
            "liveNow": liveNow,
            "isLive": isLive,
            "membersChip": membersChip,
            "companionVideoId": companionVideoID ?? NSNull(),
        ]
    }

    /// A calendar entry of an event's `view`.
    static func entry(_ startsOn: String, at startsAt: String? = nil, saleMark: String? = nil) -> [String:
        Any]
    {
        [
            "startsOn": startsOn,
            "startsAt": startsAt ?? NSNull(),
            "timePrecision": startsAt == nil ? "unknown" : "exact",
            "saleMark": saleMark ?? NSNull(),
        ]
    }

    static func event(
        id: String, title: String = "Synthetic entry", startsOn: String, startsAt: String? = nil,
        type: String = "stream", state: String = "upcoming", entries: [[String: Any]]? = nil,
        links: [[String: Any]] = [], url: String? = nil, saleWindow: [String: Any]? = nil
    ) -> [String: Any] {
        var event: [String: Any] = [
            "id": id,
            "source": "synthetic",
            "title": title,
            "startsOn": startsOn,
            "eventType": type,
            "links": links,
            "view": [
                "state": state,
                "typeCode": type,
                "activityContext": "",
                "isWork": false,
                "calendarEntries": entries ?? [entry(startsOn, at: startsAt)],
            ],
        ]
        event["startsAt"] = startsAt
        event["url"] = url
        event["saleWindow"] = saleWindow
        return event
    }

    static func link(_ platform: String, _ url: String?, live: Bool = false) -> [String: Any] {
        ["platform": platform, "url": url ?? NSNull(), "liveStatus": live ? "live" : NSNull()]
    }

    static func video(
        id: String, title: String = "Synthetic video", source: String = "youtube",
        scheduledAt: String? = nil, publishedAt: String? = nil, alternates: [[String: Any]] = []
    ) -> [String: Any] {
        var video: [String: Any] = [
            "id": id,
            "source": source,
            "title": title,
            "url": "https://example.com/watch/" + id,
            "thumbnailUrl": "https://example.com/thumb/" + id,
            "thumbnailStatus": "ready",
            "isUpcoming": scheduledAt != nil,
            "alternates": alternates,
            "view": [
                "phase": "upcoming", "formCode": "stream", "shelfGroup": "", "latestEligible": true,
                "focusEligible": true, "tagContext": "stream",
            ],
        ]
        video["scheduledAt"] = scheduledAt
        video["publishedAt"] = publishedAt
        return video
    }

    /// An instant from an ISO 8601 string, for `now` in tests.
    static func instant(_ value: String) throws -> Date {
        guard let date = KanoNaviDateCoding.date(from: value) else {
            throw FixtureError.invalidInstant(value)
        }
        return date
    }

    enum FixtureError: Error {
        case invalidInstant(String)
    }
}
