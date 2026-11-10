import Foundation
import KanoNaviCore
import WidgetKit

/// A moment in the Upcoming timeline.
nonisolated struct UpcomingEntry: TimelineEntry, Equatable, Sendable {
    let date: Date
    let content: UpcomingContent

    /// The Japan date the entry falls on.
    var today: JapanDate { JapanDate.date(from: date) }

    /// The schedule, when there is one.
    var schedule: WidgetSchedule? {
        if case .schedule(let schedule) = content { schedule } else { nil }
    }

    /// The link for taps outside an entry: the schedule on this Japan date.
    var scheduleURL: URL { WidgetDeepLink.schedule(today) }

    /// Ranks a live entry above others in a Smart Stack.
    var relevance: TimelineEntryRelevance? {
        let isLive = schedule?.items.contains { $0.isLive(at: date) } ?? false
        return TimelineEntryRelevance(score: isLive ? 1 : 0.1)
    }
}
