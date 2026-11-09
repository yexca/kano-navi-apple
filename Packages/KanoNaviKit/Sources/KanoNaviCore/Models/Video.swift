import Foundation

public struct Video: Codable, Equatable, Sendable {
    public var id: String
    public var source: String
    public var title: String
    public var publishedAt: Date?
    public var scheduledAt: Date?
    public var endsAt: Date?
    public var url: URL
    public var thumbnailURL: URL?
    public var thumbnailStatus: String
    public var kind: String?
    public var tag: String?
    public var isUpcoming: Bool
    public var isCancelled: Bool?
    public var liveStatus: LiveStatus?
    public var durationSeconds: Int?
    public var isShort: Bool?
    public var availability: VideoAvailability?
    public var translations: Translations?
    public var sourceLanguage: String?
    public var alternates: [VideoAlternate]?
    public var view: VideoView?
    enum CodingKeys: String, CodingKey {
        case id, source, title, publishedAt, scheduledAt, endsAt, url
        case thumbnailURL = "thumbnailUrl"
        case thumbnailStatus, kind, tag, isUpcoming, isCancelled, liveStatus, durationSeconds, isShort,
            availability, translations, sourceLanguage, alternates, view
    }
}
