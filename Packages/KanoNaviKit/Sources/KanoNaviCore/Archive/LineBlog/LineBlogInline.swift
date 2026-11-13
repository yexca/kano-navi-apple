import Foundation

/// A run inside a block, by its `type`. A type this app does not know decodes
/// as `unknown` instead of failing the article.
public enum LineBlogInline: Codable, Equatable, Sendable {
    /// Text; line breaks are `\n`.
    case text(String)
    case link(LineBlogLink)
    case image(LineBlogImage)
    /// An inline type this app does not know; its fields are dropped.
    case unknown(type: String)

    private enum CodingKeys: String, CodingKey {
        case type, text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text": self = .text(try container.decode(String.self, forKey: .text))
        case "link": self = .link(try LineBlogLink(from: decoder))
        case "image": self = .image(try LineBlogImage(from: decoder))
        default: self = .unknown(type: type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch self {
        case .text(let text): try container.encode(text, forKey: .text)
        case .link(let link): try link.encode(to: encoder)
        case .image(let image): try image.encode(to: encoder)
        case .unknown: break
        }
    }

    /// The inline's `type` code.
    public var type: String {
        switch self {
        case .text: "text"
        case .link: "link"
        case .image: "image"
        case .unknown(let type): type
        }
    }

    func resolvingMedia(against baseURL: URL) -> LineBlogInline {
        switch self {
        case .text, .unknown:
            return self
        case .link(var link):
            link.content = link.content.resolvingMedia(against: baseURL)
            return .link(link)
        case .image(let image):
            return .image(image.resolvingMedia(against: baseURL))
        }
    }
}

extension [LineBlogInline] {
    func resolvingMedia(against baseURL: URL) -> [LineBlogInline] {
        map { $0.resolvingMedia(against: baseURL) }
    }
}

/// A link around inlines.
public struct LineBlogLink: Codable, Equatable, Sendable {
    /// The link as written (provenance); opened only on request.
    public var href: URL
    public var content: [LineBlogInline]
    /// The archived article the link opens in the app, or `nil`.
    public var articleID: String?

    private enum CodingKeys: String, CodingKey {
        case href, content
        case articleID = "articleId"
    }
}

/// A picture in the text. Its `type` is always `image`.
public struct LineBlogImage: Codable, Equatable, Sendable {
    /// The archived file, or `nil` for a picture the archive never captured.
    public var image: LineBlogMedia?
    /// Readable alternative text.
    public var alt: String?
    /// A pictograph drawn at text size and not opened in a viewer.
    public var emoji: Bool
    /// The link the picture opened (provenance).
    public var href: URL?
    /// Where the archived bytes came from (provenance).
    public var sourceURL: URL?
    /// The original address of a picture never captured (provenance).
    public var remoteURL: URL?
    /// How a picture added after the recovery archive was found, or `nil`.
    public var recovery: LineBlogImageRecovery?

    private enum CodingKeys: String, CodingKey {
        case type, image, alt, emoji, href
        case sourceURL = "sourceUrl"
        case remoteURL = "remoteUrl"
        case recovery
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        image = try container.decodeIfPresent(LineBlogMedia.self, forKey: .image)
        alt = try container.decodeIfPresent(String.self, forKey: .alt)
        emoji = try container.decode(Bool.self, forKey: .emoji)
        href = try container.decodeIfPresent(URL.self, forKey: .href)
        sourceURL = try container.decodeIfPresent(URL.self, forKey: .sourceURL)
        remoteURL = try container.decodeIfPresent(URL.self, forKey: .remoteURL)
        recovery = try container.decodeIfPresent(LineBlogImageRecovery.self, forKey: .recovery)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("image", forKey: .type)
        try container.encode(image, forKey: .image)
        try container.encode(alt, forKey: .alt)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(href, forKey: .href)
        try container.encode(sourceURL, forKey: .sourceURL)
        try container.encode(remoteURL, forKey: .remoteURL)
        try container.encode(recovery, forKey: .recovery)
    }

    func resolvingMedia(against baseURL: URL) -> LineBlogImage {
        var value = self
        value.image = image?.resolvingMedia(against: baseURL)
        return value
    }
}
