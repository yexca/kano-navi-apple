import Foundation

/// A stored video dated after the upload list that the Works page shows above it.
public struct WorksRecentUpload: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var source: WorksVideoSource
    public var title: String
    /// The video's page on its platform.
    public var url: URL
    /// A premiere's scheduled time or the publish time.
    public var publishedAt: Date?
    public var cover: WorksUploadCover?
    public var origin: WorksRecentOrigin
    public var translations: Translations?
    public var sourceLanguage: String?
    /// For a YouTube video, its merged Bilibili uploads.
    public var alternates: [VideoAlternate]
}
