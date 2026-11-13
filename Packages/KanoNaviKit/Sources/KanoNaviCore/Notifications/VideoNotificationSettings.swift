import Foundation

/// Which video shelves raise new-video notifications.
public struct VideoNotificationSettings: Codable, Equatable, Sendable {
    /// Regular uploads and premieres (`shelfGroup == "work"`).
    public var works: Bool
    /// Vertical Shorts (`shelfGroup == "short"`).
    public var shorts: Bool
    /// Completed stream archives (`shelfGroup == "archive"`).
    public var archives: Bool

    public init(
        works: Bool = true,
        shorts: Bool = true,
        archives: Bool = false
    ) {
        self.works = works
        self.shorts = shorts
        self.archives = archives
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        works = try container.decodeIfPresent(Bool.self, forKey: .works) ?? true
        shorts = try container.decodeIfPresent(Bool.self, forKey: .shorts) ?? true
        archives = try container.decodeIfPresent(Bool.self, forKey: .archives) ?? false
    }

    public var hasAnyEnabled: Bool {
        works || shorts || archives
    }
}
