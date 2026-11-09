import Foundation

public struct SpotlightProjection: Codable, Equatable, Sendable {
    public enum Mode: Codable, Equatable, Sendable { case next, latest, unknown(String)
        public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = v == "next" ? .next : v == "latest" ? .latest : .unknown(v) }
        public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
        public var rawValue: String { switch self { case .next:"next"; case .latest:"latest"; case .unknown(let v):v } }
    }
    public var mode: Mode
    public var eventID: String?
    public var videoID: String?
    public var liveNow: Bool
    public var isLive: Bool
    public var membersChip: Bool
    public var companionVideoID: String?
    enum CodingKeys: String, CodingKey { case mode, eventID = "eventId", videoID = "videoId", liveNow, isLive, membersChip, companionVideoID = "companionVideoId" }
}

public struct ShelfProjection: Codable, Equatable, Sendable {
    public var leadID: String?
    public var leadIsFeatured: Bool
    public var reservations: [String]
    public var works: [String]
    public var archives: [String]
    public var shorts: [String]
    enum CodingKeys: String, CodingKey { case leadID = "leadId", leadIsFeatured, reservations, works, archives, shorts }
}

public struct ProjectionFocus: Codable, Equatable, Sendable {
    public var eventIDs: [String]
    public var videoIDs: [String]
    public init(eventIDs: [String], videoIDs: [String]) { self.eventIDs = eventIDs; self.videoIDs = videoIDs }
    enum CodingKeys: String, CodingKey { case eventIDs = "eventIds", videoIDs = "videoIds" }
}

public struct DashboardProjection: Codable, Equatable, Sendable {
    public var version: Int
    public var nextTransitionAt: Date?
    public var focus: ProjectionFocus
    public var spotlight: SpotlightProjection?
    public var sales: [String]
    public var shelf: ShelfProjection
    enum CodingKeys: String, CodingKey { case version, nextTransitionAt, focus, spotlight, sales, shelf }
    enum FocusKeys: String, CodingKey { case eventIDs = "eventIds", videoIDs = "videoIds" }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = try c.decode(Int.self, forKey: .version)
        nextTransitionAt = try c.decodeIfPresent(Date.self, forKey: .nextTransitionAt)
        let f = try c.nestedContainer(keyedBy: FocusKeys.self, forKey: .focus)
        focus = ProjectionFocus(eventIDs: try f.decode([String].self, forKey: .eventIDs), videoIDs: try f.decode([String].self, forKey: .videoIDs))
        spotlight = try c.decodeIfPresent(SpotlightProjection.self, forKey: .spotlight)
        sales = try c.decode([String].self, forKey: .sales)
        shelf = try c.decode(ShelfProjection.self, forKey: .shelf)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(version, forKey: .version); try c.encodeIfPresent(nextTransitionAt, forKey: .nextTransitionAt)
        var f = c.nestedContainer(keyedBy: FocusKeys.self, forKey: .focus)
        try f.encode(focus.eventIDs, forKey: .eventIDs); try f.encode(focus.videoIDs, forKey: .videoIDs)
        try c.encodeIfPresent(spotlight, forKey: .spotlight); try c.encode(sales, forKey: .sales); try c.encode(shelf, forKey: .shelf)
    }
}
