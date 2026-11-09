import Foundation

public struct FocusResource: Codable, Equatable, Sendable {
    public var videoID: String?
    public var title: String
    public var description: String?
    public var updatedAt: Date?
    public var dateLabel: String?
    public var imageURL: URL?
    public var url: URL?
    public var sourceURL: URL?
    enum CodingKeys: String, CodingKey {
        case videoID = "videoId"
        case title, description, updatedAt, dateLabel
        case imageURL = "imageUrl"
        case url
        case sourceURL = "sourceUrl"
    }
}
