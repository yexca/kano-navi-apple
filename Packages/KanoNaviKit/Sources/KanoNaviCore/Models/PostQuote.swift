import Foundation

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
  enum CodingKeys: String, CodingKey {
    case id, authorHandle, authorName, text, publishedAt, url, unavailable, media, translations,
      sourceLanguage
  }
}
