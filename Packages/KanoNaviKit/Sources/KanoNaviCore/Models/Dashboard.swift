import Foundation

public struct LiveNow: Codable, Equatable, Sendable {
    public var platform: EventPlatform
    public var url: URL
    public var title: String
    public var startedAt: Date
    public init(platform: EventPlatform, url: URL, title: String, startedAt: Date) { self.platform = platform; self.url = url; self.title = title; self.startedAt = startedAt }
}

public struct DashboardCounts: Codable, Equatable, Sendable {
    public var posts: Int
    public var upcomingEvents: Int
    public var videos: Int
}

public struct DashboardSummary: Codable, Equatable, Sendable {
    public var nextEvent: ScheduleEvent?
    public var nextStream: Video?
    public var latestVideo: Video?
    public var latestPost: Post?
    public var counts: DashboardCounts?
}

public struct TimelineItem: Codable, Equatable, Sendable {
    public var id: Int
    public var year: String
    public var title: String
    public var detail: String?
}

public struct ResourceLink: Codable, Equatable, Sendable {
    public var id: Int
    public var title: String
    public var detail: String?
    public var url: URL
    public var kind: String?
}

public struct DashboardMeta: Codable, Equatable, Sendable {
    public var fetchedAt: Date?
    public var sourceFetchedAt: [String: Date?]?
    public var lastSync: LastSync?
    public var postWindowDays: Int
    public var xAccounts: [String]
    public var bilibiliAccounts: [String]?
    public var featuredVideoID: String?
    public var eventWindow: EventWindow?
    public var revision: Int?
    enum CodingKeys: String, CodingKey { case fetchedAt, sourceFetchedAt, lastSync, postWindowDays, xAccounts, bilibiliAccounts, featuredVideoID = "featuredVideoId", eventWindow, revision }
}

public struct LastSync: Codable, Equatable, Sendable {
    public var status: String
    public var startedAt: Date?
    public var finishedAt: Date?
}

public struct EventWindow: Codable, Equatable, Sendable {
    public var from: JapanDate
    public var to: JapanDate
    public var paginated: Bool
}

public struct Dashboard: Codable, Equatable, Sendable {
    public var profile: Profile
    public var liveNow: LiveNow?
    public var projection: DashboardProjection?
    public var summary: DashboardSummary
    public var posts: [Post]
    public var events: [ScheduleEvent]
    public var videos: [Video]
    public var focus: FocusResource?
    public var timeline: [TimelineItem]
    public var resources: [ResourceLink]
    public var assets: [ScheduleAsset]
    public var scheduleImages: [ScheduleAsset]
    public var meta: DashboardMeta
}

public struct FocusResource: Codable, Equatable, Sendable {
    public var videoID: String?
    public var title: String
    public var description: String?
    public var updatedAt: Date?
    public var dateLabel: String?
    public var imageURL: URL?
    public var url: URL?
    public var sourceURL: URL?
    enum CodingKeys: String, CodingKey { case videoID = "videoId", title, description, updatedAt, dateLabel, imageURL = "imageUrl", url, sourceURL = "sourceUrl" }
}
