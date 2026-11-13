import Foundation

/// One block of an article, by its `type`. A type this app does not know
/// decodes as `unknown` instead of failing the article.
public enum LineBlogBlock: Codable, Equatable, Sendable {
    case paragraph(LineBlogParagraph)
    case quote([LineBlogInline])
    case rule
    case video(LineBlogMedia)
    case youtube(LineBlogYouTube)
    case card(LineBlogCard)
    /// A block type this app does not know; its fields are dropped.
    case unknown(type: String)

    private enum CodingKeys: String, CodingKey {
        case type, content, translations, video
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "paragraph": self = .paragraph(try LineBlogParagraph(from: decoder))
        case "quote": self = .quote(try container.decode([LineBlogInline].self, forKey: .content))
        case "rule": self = .rule
        case "video": self = .video(try container.decode(LineBlogMedia.self, forKey: .video))
        case "youtube": self = .youtube(try LineBlogYouTube(from: decoder))
        case "card": self = .card(try LineBlogCard(from: decoder))
        default: self = .unknown(type: type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch self {
        case .paragraph(let paragraph): try paragraph.encode(to: encoder)
        case .quote(let content): try container.encode(content, forKey: .content)
        case .rule, .unknown: break
        case .video(let video): try container.encode(video, forKey: .video)
        case .youtube(let youtube): try youtube.encode(to: encoder)
        case .card(let card): try card.encode(to: encoder)
        }
    }

    /// The block's `type` code.
    public var type: String {
        switch self {
        case .paragraph: "paragraph"
        case .quote: "quote"
        case .rule: "rule"
        case .video: "video"
        case .youtube: "youtube"
        case .card: "card"
        case .unknown(let type): type
        }
    }

    func resolvingMedia(against baseURL: URL) -> LineBlogBlock {
        switch self {
        case .paragraph(var paragraph):
            paragraph.content = paragraph.content.resolvingMedia(against: baseURL)
            if var translations = paragraph.translations {
                translations.zhCN = translations.zhCN?.map { $0.resolvingMedia(against: baseURL) }
                translations.en = translations.en?.map { $0.resolvingMedia(against: baseURL) }
                paragraph.translations = translations
            }
            return .paragraph(paragraph)
        case .quote(let content): return .quote(content.resolvingMedia(against: baseURL))
        case .rule, .unknown: return self
        case .video(let video): return .video(video.resolvingMedia(against: baseURL))
        case .youtube(var youtube):
            youtube.video = youtube.video?.resolvingMedia(against: baseURL)
            youtube.cover = youtube.cover?.resolvingMedia(against: baseURL)
            return .youtube(youtube)
        case .card(var card):
            card.image = card.image?.resolvingMedia(against: baseURL)
            return .card(card)
        }
    }
}

/// A paragraph of inlines, with machine translations of the Japanese.
public struct LineBlogParagraph: Codable, Equatable, Sendable {
    public var content: [LineBlogInline]
    /// Shown after the Japanese paragraph; `nil` when the paragraph has none.
    public var translations: LineBlogParagraphTranslations?

    private enum CodingKeys: String, CodingKey {
        case content, translations
    }

    /// A paragraph of only non-pictograph pictures, drawn as a row of figures.
    public var isFigureRow: Bool {
        content.isEmpty == false
            && content.allSatisfy { inline in
                if case .image(let image) = inline { return image.emoji == false }
                return false
            }
    }
}

/// The machine translations of a paragraph. Each is a list of translated
/// paragraphs, each a list of inlines; `nil` for a language without one.
public struct LineBlogParagraphTranslations: Codable, Equatable, Sendable {
    public var zhCN: [[LineBlogInline]]?
    public var en: [[LineBlogInline]]?

    private enum CodingKeys: String, CodingKey {
        case zhCN = "zh-CN"
        case en
    }

    /// The translation into `locale`; always `nil` for Japanese, the original.
    public subscript(locale: ContentLocale) -> [[LineBlogInline]]? {
        switch locale {
        case .ja: nil
        case .zhHans: zhCN
        case .en: en
        }
    }

    /// Whether neither language has a translation.
    public var isEmpty: Bool { (zhCN?.isEmpty ?? true) && (en?.isEmpty ?? true) }
}

/// A YouTube embed with its downloaded copy.
public struct LineBlogYouTube: Codable, Equatable, Sendable {
    public var videoID: String
    /// The video's page on YouTube (provenance).
    public var watchURL: URL
    /// The downloaded copy, or `nil`.
    public var video: LineBlogMedia?
    public var cover: LineBlogMedia?
    /// Where the cover came from (provenance).
    public var coverSourceURL: URL?
    /// The archived capture of the video page (provenance).
    public var archiveURL: URL?

    private enum CodingKeys: String, CodingKey {
        case videoID = "videoId"
        case watchURL = "watchUrl"
        case video, cover
        case coverSourceURL = "coverSourceUrl"
        case archiveURL = "archiveUrl"
    }
}

/// A link card.
public struct LineBlogCard: Codable, Equatable, Sendable {
    public var title: String
    /// The linked page (provenance).
    public var url: URL
    /// The archived article the card opens in the app, or `nil`.
    public var articleID: String?
    /// The archived capture of the linked page (provenance).
    public var archiveURL: URL?
    public var description: String?
    public var image: LineBlogImage?

    private enum CodingKeys: String, CodingKey {
        case title, url
        case articleID = "articleId"
        case archiveURL = "archiveUrl"
        case description, image
    }
}
