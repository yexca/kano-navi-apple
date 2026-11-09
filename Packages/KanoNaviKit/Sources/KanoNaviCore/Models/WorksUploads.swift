import Foundation

public struct WorksUploadCover: Codable, Equatable, Sendable {
    public var url: URL
    public var width: Int
    public var height: Int
}

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

public struct WorksUploadState: Codable, Equatable, Sendable {
    public var cover: WorksUploadCover?
    public var videos: [WorksUploadVideo]
}

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

public struct WorksUploadsResponse: Codable, Equatable, Sendable {
    public var updatedAt: JapanDate
    public var revision: Int
    public var uploads: [String: WorksUploadState]
    public var recent: [WorksRecentUpload]?
    public var recentTotal: Int?
}
