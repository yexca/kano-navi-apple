import Foundation

/// Notification grouping threads used for banner stacking and burst coalescing.
public enum NotificationThread: String, CaseIterable, Codable, Equatable, Hashable, Sendable {
    case live = "kanonavi.live"
    case schedule = "kanonavi.schedule"
    case videos = "kanonavi.videos"
    case posts = "kanonavi.posts"
    case reminders = "kanonavi.reminders"
}
