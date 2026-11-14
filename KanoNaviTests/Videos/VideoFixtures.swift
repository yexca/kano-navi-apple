import Foundation
import KanoNaviCore

/// Synthetic video records in the API's JSON shape, decoded with the API's
/// own decoder. URLs use the reserved `example.com` domain.
enum VideoFixtures {
    static func json(
        id: String, source: String = "youtube", phase: String = "past", formCode: String? = "video",
        shelfGroup: String = "work", tag: String? = nil, availability: String? = "public",
        isShort: Bool = false, scheduledAt: String? = nil, publishedAt: String? = "2026-11-09T10:00:00Z",
        alternates: [[String: Any]] = [], durationSeconds: Int? = nil, kind: String? = nil,
        tagContext: String = "work"
    ) -> [String: Any] {
        var video: [String: Any] = [
            "id": id,
            "source": source,
            "title": "Synthetic " + id,
            "url": "https://example.com/watch/" + id,
            "thumbnailUrl": "https://example.com/thumb/" + id,
            "thumbnailStatus": "ready",
            "isUpcoming": phase == "upcoming",
            "isShort": isShort,
            "alternates": alternates,
            "view": [
                "phase": phase, "formCode": formCode.map { $0 as Any } ?? NSNull(), "shelfGroup": shelfGroup,
                "latestEligible": true, "focusEligible": false, "tagContext": tagContext,
            ],
        ]
        video["scheduledAt"] = scheduledAt
        video["publishedAt"] = publishedAt
        video["tag"] = tag
        video["availability"] = availability
        video["durationSeconds"] = durationSeconds
        video["kind"] = kind
        return video
    }

    static func video(_ json: [String: Any]) throws -> Video {
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(Video.self, from: data)
    }

    static func shelf(
        lead: String? = nil, featured: Bool = false, reservations: [String] = [], works: [String] = [],
        archives: [String] = [], shorts: [String] = []
    ) -> [String: Any] {
        [
            "leadId": lead ?? NSNull(), "leadIsFeatured": featured, "reservations": reservations,
            "works": works, "archives": archives, "shorts": shorts,
        ]
    }
}
