import Foundation

public struct Translation: Codable, Equatable, Sendable {
    public var text: String
    public var origin: TranslationOrigin
    public var platform: String?
    public init(text: String, origin: TranslationOrigin, platform: String? = nil) { self.text = text; self.origin = origin; self.platform = platform }
}

public struct Translations: Codable, Equatable, Sendable {
    public var en: Translation?
    public var ja: Translation?
    public var zhCN: Translation?
    public init(en: Translation? = nil, ja: Translation? = nil, zhCN: Translation? = nil) { self.en = en; self.ja = ja; self.zhCN = zhCN }
    enum CodingKeys: String, CodingKey { case en, ja, zhCN = "zh-CN" }
    public subscript(locale: ContentLocale) -> Translation? { switch locale { case .en: en; case .ja: ja; case .zhHans: zhCN } }
}

public struct PostQuote: Codable, Equatable, Sendable {
    public var id: String?
    public var authorHandle: String?
    public var authorName: String?
    public var text: String?
    public var publishedAt: Date?
    public var url: URL
    public var unavailable: Bool
    public var media: [MediaItem]
    public var translations: Translations?
    public var sourceLanguage: String?
    enum CodingKeys: String, CodingKey { case id, authorHandle, authorName, text, publishedAt, url, unavailable, media, translations, sourceLanguage }
}

public struct Post: Codable, Equatable, Sendable {
    public var id: String
    public var source: String
    public var accountHandle: String?
    public var accountURL: URL?
    public var publishedAt: Date
    public var text: String
    public var url: URL
    public var media: [MediaItem]
    public var mediaURL: URL?
    public var mediaStatus: String
    public var likes: Int?
    public var reposts: Int?
    public var replies: Int?
    public var type: String?
    public var translations: Translations?
    public var sourceLanguage: String?
    public var quote: PostQuote?
    public var promoted: Bool?
    enum CodingKeys: String, CodingKey { case id, source, accountHandle, accountURL = "accountUrl", publishedAt, text, url, media, mediaURL = "mediaUrl", mediaStatus, likes, reposts, replies, type, translations, sourceLanguage, quote, promoted }
}
