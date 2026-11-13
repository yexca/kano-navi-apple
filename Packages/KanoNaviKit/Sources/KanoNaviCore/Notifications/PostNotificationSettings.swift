import Foundation

/// Which post categories raise new-post notifications.
public struct PostNotificationSettings: Codable, Equatable, Sendable {
    /// Kano's own posts on X.
    public var ownXPosts: Bool
    /// Kano's own dynamics on Bilibili.
    public var bilibiliPosts: Bool
    /// Related accounts' posts promoted onto the board.
    public var promotedPosts: Bool

    public init(
        ownXPosts: Bool = true,
        bilibiliPosts: Bool = true,
        promotedPosts: Bool = false
    ) {
        self.ownXPosts = ownXPosts
        self.bilibiliPosts = bilibiliPosts
        self.promotedPosts = promotedPosts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ownXPosts = try container.decodeIfPresent(Bool.self, forKey: .ownXPosts) ?? true
        bilibiliPosts = try container.decodeIfPresent(Bool.self, forKey: .bilibiliPosts) ?? true
        promotedPosts = try container.decodeIfPresent(Bool.self, forKey: .promotedPosts) ?? false
    }

    public var hasAnyEnabled: Bool {
        ownXPosts || bilibiliPosts || promotedPosts
    }
}
