import Foundation

/// Semantic payload of an immediate notification discovered by diffing snapshots.
public enum PlannedNotificationKind: Equatable, Sendable {
    case unscheduledLive(LiveNow)
    case eventLive(ScheduleEvent)
    case newPost(Post)
    case newVideo(Video, isArchive: Bool, isShort: Bool)
    case newEvent(ScheduleEvent)
    case eventCancelled(ScheduleEvent)
    case eventRescheduled(ScheduleEvent)
    case summary(thread: NotificationThread, additionalCount: Int)
}
