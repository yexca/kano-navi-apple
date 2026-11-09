import Foundation

public struct MediaItem: Codable, Equatable, Sendable {
    public var id: String?
    public var url: URL?
    public var status: String
    public var sourceURL: URL?
    public var position: Int?
    public var width: Int?
    public var height: Int?
    public var alt: String?

    public init(
        id: String? = nil, url: URL? = nil, status: String, sourceURL: URL? = nil, position: Int? = nil,
        width: Int? = nil, height: Int? = nil, alt: String? = nil
    ) {
        self.id = id
        self.url = url
        self.status = status
        self.sourceURL = sourceURL
        self.position = position
        self.width = width
        self.height = height
        self.alt = alt
    }
    enum CodingKeys: String, CodingKey {
        case id, url, status
        case sourceURL = "sourceUrl"
        case position, width, height, alt
    }
}
