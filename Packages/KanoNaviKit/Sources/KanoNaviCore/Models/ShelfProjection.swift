import Foundation

public struct ShelfProjection: Codable, Equatable, Sendable {
    public var leadID: String?
    public var leadIsFeatured: Bool
    public var reservations: [String]
    public var works: [String]
    public var archives: [String]
    public var shorts: [String]
    enum CodingKeys: String, CodingKey {
        case leadID = "leadId"
        case leadIsFeatured, reservations, works, archives, shorts
    }
}
