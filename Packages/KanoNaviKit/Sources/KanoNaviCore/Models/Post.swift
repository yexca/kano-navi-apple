import Foundation

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
    enum CodingKeys: String, CodingKey {
        case id, source, accountHandle
        case accountURL = "accountUrl"
        case publishedAt, text, url, media
        case mediaURL = "mediaUrl"
        case mediaStatus, likes, reposts, replies, type, translations, sourceLanguage, quote, promoted
    }
}
