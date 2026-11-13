import Foundation

/// A stored video of an upload, with its shown title.
public struct WorksUploadVideo: Codable, Equatable, Sendable {
    public var source: WorksVideoSource
    public var id: String
    public var title: String
    /// The video's page on its platform.
    public var url: URL
    public var publishedAt: Date?
    public var scheduledAt: Date?
    public var durationSeconds: Int?
    public var availability: VideoAvailability?
    public var translations: Translations?
    public var sourceLanguage: String?
}
