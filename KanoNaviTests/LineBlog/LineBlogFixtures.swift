import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Synthetic LINE BLOG records in the API's JSON shape, decoded with the
/// API's own decoder. Addresses use the reserved `example.com` domain.
nonisolated enum LineBlogFixtures {
    typealias JSON = [String: Any]

    static let media = "https://example.com/media/lineblog/"

    // MARK: Inlines

    static func text(_ text: String) -> JSON {
        ["type": "text", "text": text]
    }

    static func link(_ href: String, articleID: String? = nil, _ content: JSON...) -> JSON {
        [
            "type": "link", "href": href, "articleId": articleID.map { $0 as Any } ?? NSNull(),
            "content": content,
        ]
    }

    /// A pictograph: a small picture drawn at text size.
    static func pictograph(_ name: String?, alt: String? = nil) -> JSON {
        image(name, alt: alt, emoji: true, width: 20, height: 20)
    }

    /// A picture; `name` of `nil` is one the archive never captured.
    static func image(
        _ name: String?, alt: String? = nil, emoji: Bool = false, width: Int = 640, height: Int = 480,
        href: String? = nil, sourceURL: String? = nil, remoteURL: String? = nil, recovery: String? = nil
    ) -> JSON {
        var image: JSON = ["type": "image", "emoji": emoji]
        image["image"] = name.map { mediaObject($0, width: width, height: height) as Any } ?? NSNull()
        image["alt"] = alt.map { $0 as Any } ?? NSNull()
        image["href"] = href.map { $0 as Any } ?? NSNull()
        image["sourceUrl"] = sourceURL.map { $0 as Any } ?? NSNull()
        image["remoteUrl"] = remoteURL.map { $0 as Any } ?? NSNull()
        image["recovery"] = recovery.map { $0 as Any } ?? NSNull()
        return image
    }

    static func mediaObject(_ name: String, width: Int? = 640, height: Int? = 480) -> JSON {
        [
            "url": media + name, "width": width.map { $0 as Any } ?? NSNull(),
            "height": height.map { $0 as Any } ?? NSNull(),
            "mimeType": name.hasSuffix(".mp4")
                ? "video/mp4" : name.hasSuffix(".png") ? "image/png" : "image/jpeg",
        ]
    }

    // MARK: Blocks

    static func paragraph(_ content: JSON..., chinese: [[JSON]]? = nil, english: [[JSON]]? = nil) -> JSON {
        [
            "type": "paragraph", "content": content,
            "translations": [
                "zh-CN": chinese.map { $0 as Any } ?? NSNull(), "en": english.map { $0 as Any } ?? NSNull(),
            ],
        ]
    }

    static func quote(_ content: JSON...) -> JSON {
        ["type": "quote", "content": content]
    }

    static var rule: JSON { ["type": "rule"] }

    static func video(_ name: String) -> JSON {
        ["type": "video", "video": mediaObject(name, width: nil, height: nil)]
    }

    static func youtube(id: String = "synthetic01", video: String? = nil, cover: String? = nil) -> JSON {
        [
            "type": "youtube", "videoId": id, "watchUrl": "https://video.example.com/watch?v=" + id,
            "video": video.map { mediaObject($0, width: nil, height: nil) as Any } ?? NSNull(),
            "cover": cover.map { mediaObject($0, width: 480, height: 360) as Any } ?? NSNull(),
            "coverSourceUrl": "https://img.example.com/" + id + ".jpg",
            "archiveUrl": "https://archive.example.com/watch?v=" + id,
        ]
    }

    static func card(
        title: String = "Synthetic card", url: String = "https://shop.example.com/item",
        articleID: String? = nil,
        description: String? = nil, image: String? = nil
    ) -> JSON {
        [
            "type": "card", "title": title, "url": url,
            "articleId": articleID.map { $0 as Any } ?? NSNull(),
            "archiveUrl": "https://archive.example.com/card",
            "description": description.map { $0 as Any } ?? NSNull(),
            "image": image.map { self.image($0, width: 200, height: 200) as Any } ?? NSNull(),
        ]
    }

    // MARK: Documents

    static func article(_ blocks: JSON...) throws -> LineBlogArticle {
        try article(blocks: blocks)
    }

    static func article(blocks: [JSON]) throws -> LineBlogArticle {
        let json: JSON = [
            "id": "1001", "published": "2017-03-04T03:00:00.000Z",
            "title": ["ja": "合成の記事", "zh-CN": "合成文章", "en": "Synthetic article"],
            "url": "https://blog.example.com/archives/1001.html",
            "archiveUrl": "https://archive.example.com/blog/1001", "blocks": blocks,
        ]
        return try decode(LineBlogArticle.self, from: json)
    }

    static func layout(_ blocks: JSON...) throws -> LineBlogArticleLayout {
        LineBlogArticleLayout(article: try article(blocks: blocks))
    }

    static func summary(id: String, published: String, comments: Int = 0) throws -> LineBlogPostSummary {
        let json: JSON = [
            "id": id, "published": published,
            "title": ["ja": "記事 " + id, "zh-CN": NSNull(), "en": "Article " + id], "thumbnail": NSNull(),
            "commentCount": comments,
        ]
        return try decode(LineBlogPostSummary.self, from: json)
    }

    static func rating(icon: String, value: Int) throws -> LineBlogRating {
        try decode(LineBlogRating.self, from: ["icon": icon, "value": value])
    }

    static func source(_ name: String, width: Int = 640, height: Int = 480) -> MediaImageSource {
        MediaImageSource(url: URL(string: media + name)!, width: width, height: height)
    }

    private static func decode<Value: Decodable>(_ type: Value.Type, from json: JSON) throws -> Value {
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(type, from: data)
    }
}
