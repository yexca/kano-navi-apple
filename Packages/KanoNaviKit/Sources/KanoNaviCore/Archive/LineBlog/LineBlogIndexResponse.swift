import Foundation

/// `GET /api/lineblog`: every archived article and the months with articles.
public struct LineBlogIndexResponse: Codable, Equatable, Sendable {
    /// The Japan date of the newest archived article or comment.
    public var updatedAt: JapanDate
    /// The blog's original address (provenance).
    public var originalBlogURL: URL
    /// Newest first.
    public var posts: [LineBlogPostSummary]
    /// Newest first.
    public var months: [LineBlogMonth]

    enum CodingKeys: String, CodingKey {
        case updatedAt
        case originalBlogURL = "originalBlogUrl"
        case posts, months
    }

    public func resolvingMedia(against baseURL: URL) -> LineBlogIndexResponse {
        var value = self
        value.posts = posts.map { post in
            var post = post
            post.thumbnail = post.thumbnail?.resolvingMedia(against: baseURL)
            return post
        }
        return value
    }
}

/// An article in the archive's list.
public struct LineBlogPostSummary: Codable, Equatable, Sendable, Identifiable {
    /// The article number as a string, such as `13162309`.
    public var id: String
    /// Show in Asia/Tokyo.
    public var published: Date
    /// Japanese is the original; resolve with `LocalizedText.japaneseOriginalFallback`.
    public var title: LocalizedText
    /// The first archived picture or video cover.
    public var thumbnail: LineBlogMedia?
    /// Archived comments, 0 without any.
    public var commentCount: Int
}

/// A Japan month with articles.
public struct LineBlogMonth: Codable, Equatable, Sendable {
    /// `YYYY-MM`.
    public var month: String
    public var total: Int
}
