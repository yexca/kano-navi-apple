import Foundation

/// `GET /api/lineblog/posts/{id}/comments`: the article's archived comments,
/// newest first, in Japanese as archived; empty for an article without any.
public struct LineBlogCommentsResponse: Codable, Equatable, Sendable {
    public var updatedAt: JapanDate
    public var comments: [LineBlogComment]
}

/// An archived comment. Commenters' links are never kept.
public struct LineBlogComment: Codable, Equatable, Sendable, Identifiable {
    /// The comment's number; deleted comments leave gaps.
    public var number: Int
    /// The display name.
    public var author: String
    /// To the minute in Japan time; show in Asia/Tokyo.
    public var posted: Date
    /// Plain text with `\n` line breaks.
    public var body: String
    public var rating: LineBlogRating?

    public var id: Int { number }
}

/// A comment's rating.
public struct LineBlogRating: Codable, Equatable, Sendable {
    public var icon: LineBlogRatingIcon
    /// 1–5.
    public var value: Int
}
