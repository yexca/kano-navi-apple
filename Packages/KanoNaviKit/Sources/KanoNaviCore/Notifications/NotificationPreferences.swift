import Foundation

/// User-chosen local notification filters and timed reminder settings.
public struct NotificationPreferences: Codable, Equatable, Sendable {
    public var isEnabled: Bool
    public var notifyLiveNow: Bool
    public var posts: PostNotificationSettings
    public var videos: VideoNotificationSettings
    public var schedule: ScheduleNotificationSettings
    public var includeMembersOnly: Bool
    public var eventReminderLead: EventReminderLead
    public var notifySaleOpens: Bool
    public var saleCloseLead: SaleCloseReminderLead

    public init(
        isEnabled: Bool = false,
        notifyLiveNow: Bool = true,
        posts: PostNotificationSettings = PostNotificationSettings(),
        videos: VideoNotificationSettings = VideoNotificationSettings(),
        schedule: ScheduleNotificationSettings = ScheduleNotificationSettings(),
        includeMembersOnly: Bool = true,
        eventReminderLead: EventReminderLead = .tenMinutes,
        notifySaleOpens: Bool = true,
        saleCloseLead: SaleCloseReminderLead = .oneHour
    ) {
        self.isEnabled = isEnabled
        self.notifyLiveNow = notifyLiveNow
        self.posts = posts
        self.videos = videos
        self.schedule = schedule
        self.includeMembersOnly = includeMembersOnly
        self.eventReminderLead = eventReminderLead
        self.notifySaleOpens = notifySaleOpens
        self.saleCloseLead = saleCloseLead
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        notifyLiveNow = try container.decodeIfPresent(Bool.self, forKey: .notifyLiveNow) ?? true
        posts =
            try container.decodeIfPresent(PostNotificationSettings.self, forKey: .posts)
            ?? PostNotificationSettings()
        videos =
            try container.decodeIfPresent(VideoNotificationSettings.self, forKey: .videos)
            ?? VideoNotificationSettings()
        schedule =
            try container.decodeIfPresent(ScheduleNotificationSettings.self, forKey: .schedule)
            ?? ScheduleNotificationSettings()
        includeMembersOnly =
            try container.decodeIfPresent(Bool.self, forKey: .includeMembersOnly) ?? true
        eventReminderLead =
            try container.decodeIfPresent(EventReminderLead.self, forKey: .eventReminderLead)
            ?? .tenMinutes
        notifySaleOpens =
            try container.decodeIfPresent(Bool.self, forKey: .notifySaleOpens) ?? true
        saleCloseLead =
            try container.decodeIfPresent(SaleCloseReminderLead.self, forKey: .saleCloseLead)
            ?? .oneHour
    }

    public var hasImmediateAlertsEnabled: Bool {
        isEnabled
            && (notifyLiveNow || posts.hasAnyEnabled || videos.hasAnyEnabled || schedule.hasAnyEnabled)
    }

    public var hasTimedRemindersEnabled: Bool {
        isEnabled && (eventReminderLead != .off || notifySaleOpens || saleCloseLead != .off)
    }
}
