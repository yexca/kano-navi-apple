import Foundation

/// Output of one notification planning pass: updated baseline, immediate diff
/// notifications, and future calendar reminders.
public struct NotificationEvaluation: Equatable, Sendable {
    public var baseline: NotificationBaseline
    public var immediate: [PlannedNotification]
    public var reminders: [ScheduledReminder]

    public init(
        baseline: NotificationBaseline,
        immediate: [PlannedNotification],
        reminders: [ScheduledReminder]
    ) {
        self.baseline = baseline
        self.immediate = immediate
        self.reminders = reminders
    }
}
