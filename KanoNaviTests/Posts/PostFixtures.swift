import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Synthetic post records in the API's JSON shape, decoded with the API's
/// own decoder. URLs use the reserved `example.com` domain.
enum PostFixtures {
    static func json(
        id: String, source: String = "x", handle: String? = "synthetic", text: String = "Synthetic post",
        media: [[String: Any]] = [], mediaURL: String? = nil, mediaStatus: String = "none",
        quote: [String: Any]? = nil, promoted: Bool? = nil
    ) -> [String: Any] {
        var post: [String: Any] = [
            "id": id,
            "source": source,
            "accountHandle": handle ?? NSNull(),
            "accountUrl": NSNull(),
            "publishedAt": "2026-11-10T01:00:00Z",
            "text": text,
            "url": "https://example.com/post/" + id,
            "media": media,
            "mediaUrl": mediaURL ?? NSNull(),
            "mediaStatus": mediaStatus,
            "sourceLanguage": "ja",
        ]
        post["quote"] = quote
        post["promoted"] = promoted
        return post
    }

    /// - Parameter kind: The media's `kind`; `nil` leaves the field out.
    static func media(
        _ id: String, status: String = "ready", url: String? = nil, kind: String? = nil
    ) -> [String: Any] {
        var media: [String: Any] = [
            "id": id, "status": status, "url": url ?? "https://example.com/media/" + id, "width": 96,
            "height": 64,
        ]
        media["kind"] = kind
        return media
    }

    static func quote(
        unavailable: Bool = false, name: String? = nil, handle: String? = "quoted", text: String? = "Quoted",
        media: [[String: Any]] = []
    ) -> [String: Any] {
        [
            "id": "Q1", "authorHandle": handle ?? NSNull(), "authorName": name ?? NSNull(),
            "text": text ?? NSNull(), "publishedAt": "2026-11-09T21:00:00Z",
            "url": "https://example.com/post/Q1", "unavailable": unavailable, "media": media,
        ]
    }

    static func post(_ json: [String: Any]) throws -> Post {
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(Post.self, from: data)
    }

    @MainActor static func card(
        _ json: [String: Any], accountAvatars: [String: URL?]? = nil, profileAvatarURL: URL? = nil
    ) throws -> PostCard {
        PostCard(post: try post(json), accountAvatars: accountAvatars, profileAvatarURL: profileAvatarURL)
    }
}
