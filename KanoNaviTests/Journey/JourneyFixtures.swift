import Foundation
import KanoNaviCore

/// Synthetic Journey records on `example.com`, decoded through the real
/// models since they have no public memberwise initializers.
enum JourneyFixtures {
    static func media(
        _ id: String, branches: [String] = ["alpha"], category: String = "artwork", origin: String = "fixed",
        note: String? = nil
    ) -> [String: Any] {
        [
            "origin": origin, "id": id, "url": "https://example.com/media/journey/\(id).jpg",
            "width": 640, "height": 480, "mimeType": "image/jpeg", "branches": branches,
            "category": category, "title": ["ja": NSNull(), "zh-CN": NSNull(), "en": "Image \(id)"],
            "date": "2020-01-02", "dateKind": "post", "sourceKind": "artist", "note": note ?? NSNull(),
            "focus": NSNull(), "credit": NSNull(), "creator": NSNull(), "frameTime": NSNull(),
            "sourcePage": "https://example.com/page/\(id)", "sourceUrl": NSNull(), "originalStream": NSNull(),
            "releaseId": NSNull(), "cancelled": NSNull(), "cover": NSNull(),
        ]
    }

    static func milestone(
        _ id: String, date: String, branch: String = "alpha", media: [[String: Any]] = []
    ) -> [String: Any] {
        let precision = ["year", "month", "day"][date.split(separator: "-").count - 1]
        return [
            "id": id, "date": date, "datePrecision": precision, "dateEnd": NSNull(), "dateNote": NSNull(),
            "branch": branch, "kind": "release", "highlight": false,
            "title": ["ja": NSNull(), "zh-CN": NSNull(), "en": "Milestone \(id)"], "detail": NSNull(),
            "sourceUrl": "https://example.com/source/\(id)", "links": [], "releaseId": NSNull(),
            "media": media,
        ]
    }

    static func branch(_ id: String, tone: String = "honey") -> [String: Any] {
        [
            "id": id, "tone": tone, "since": "2010",
            "label": ["ja": NSNull(), "zh-CN": NSNull(), "en": "Branch \(id)"], "portrait": NSNull(),
        ]
    }

    static func journey(
        milestones: [[String: Any]], galleryOnly: [[String: Any]] = [],
        branches: [[String: Any]] = [branch("alpha"), branch("beta", tone: "sky")]
    ) throws -> JourneyResponse {
        let body: [String: Any] = [
            "updatedAt": "2026-11-07", "branches": branches, "milestones": milestones,
            "galleryOnly": galleryOnly,
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        return try JSONDecoder.kanoNavi().decode(JourneyResponse.self, from: data)
    }

    static func decode<Value: Decodable>(_ type: Value.Type, _ object: [String: Any]) throws -> Value {
        try JSONDecoder.kanoNavi().decode(type, from: JSONSerialization.data(withJSONObject: object))
    }
}
