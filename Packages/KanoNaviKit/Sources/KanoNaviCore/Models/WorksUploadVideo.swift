import Foundation

public struct WorksUploadVideo: Codable, Equatable, Sendable {
    public var source: String
    public var id: String
    public var title: String
    public var url: URL
    public var publishedAt: Date?
    public var scheduledAt: Date?
    public var durationSeconds: Int?
    public var availability: VideoAvailability?
    public var translations: Translations?
    public var sourceLanguage: String?
}
