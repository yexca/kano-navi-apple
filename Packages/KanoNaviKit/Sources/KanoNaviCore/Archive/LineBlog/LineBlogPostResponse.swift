import Foundation

/// `GET /api/lineblog/posts/{id}`: one article and its neighbours in pager order.
public struct LineBlogPostResponse: Codable, Equatable, Sendable {
    public var updatedAt: JapanDate
    public var post: LineBlogArticle
    /// The next older article (前の記事), or `nil` for the oldest.
    public var previousID: String?
    /// The next newer article (次の記事), or `nil` for the newest.
    public var nextID: String?

    enum CodingKeys: String, CodingKey {
        case updatedAt, post
        case previousID = "previousId"
        case nextID = "nextId"
    }

    public func resolvingMedia(against baseURL: URL) -> LineBlogPostResponse {
        var value = self
        value.post.blocks = post.blocks.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// An archived article.
public struct LineBlogArticle: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var published: Date
    public var title: LocalizedText
    /// The original address (provenance).
    public var url: URL
    /// The Wayback Machine capture it was recovered from (provenance).
    public var archiveURL: URL
    /// In reading order.
    public var blocks: [LineBlogBlock]

    enum CodingKeys: String, CodingKey {
        case id, published, title, url
        case archiveURL = "archiveUrl"
        case blocks
    }
}
