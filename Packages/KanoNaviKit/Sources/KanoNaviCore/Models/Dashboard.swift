import Foundation

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
    /// Each post account's avatar by `<source>:<account_key>`: its media URL,
    /// or `nil` for an avatar the operator hid. Accounts without a cached
    /// avatar have no entry, and older snapshots leave the map out.
    public var accountAvatars: [String: URL?]?
}
