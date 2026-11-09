import Foundation

public struct DashboardProjection: Codable, Equatable, Sendable {
    public var version: Int
    public var nextTransitionAt: Date?
    public var focus: ProjectionFocus
    public var spotlight: SpotlightProjection?
    public var sales: [String]
    public var shelf: ShelfProjection
    enum CodingKeys: String, CodingKey {
        case version, nextTransitionAt, focus, spotlight, sales, shelf
    }
    enum FocusKeys: String, CodingKey {
        case eventIDs = "eventIds"
        case videoIDs = "videoIds"
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = try c.decode(Int.self, forKey: .version)
        nextTransitionAt = try c.decodeIfPresent(Date.self, forKey: .nextTransitionAt)
        let f = try c.nestedContainer(keyedBy: FocusKeys.self, forKey: .focus)
        focus = ProjectionFocus(
            eventIDs: try f.decode([String].self, forKey: .eventIDs),
            videoIDs: try f.decode([String].self, forKey: .videoIDs))
        spotlight = try c.decodeIfPresent(SpotlightProjection.self, forKey: .spotlight)
        sales = try c.decode([String].self, forKey: .sales)
        shelf = try c.decode(ShelfProjection.self, forKey: .shelf)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(version, forKey: .version)
        try c.encodeIfPresent(nextTransitionAt, forKey: .nextTransitionAt)
        var f = c.nestedContainer(keyedBy: FocusKeys.self, forKey: .focus)
        try f.encode(focus.eventIDs, forKey: .eventIDs)
        try f.encode(focus.videoIDs, forKey: .videoIDs)
        try c.encodeIfPresent(spotlight, forKey: .spotlight)
        try c.encode(sales, forKey: .sales)
        try c.encode(shelf, forKey: .shelf)
    }
}
