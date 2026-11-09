import Foundation

public struct WorksRecentUpload: Codable, Equatable, Sendable {
    public var id: String
    public var source: String
    public var title: String
    public var url: URL
    public var publishedAt: Date
    public var cover: WorksUploadCover?
    public var origin: String
    public var translations: Translations?
    public var sourceLanguage: String?
    public var alternates: [VideoAlternate]?
}
