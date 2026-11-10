import Foundation
import KanoNaviCore
import WidgetKit

/// Supplies the Upcoming widget's timeline from the calendar API.
nonisolated struct UpcomingProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> UpcomingEntry {
        WidgetSampleData.entry(now: .now, language: .system)
    }

    func snapshot(for configuration: UpcomingConfigurationIntent, in context: Context) async
        -> UpcomingEntry
    {
        WidgetSampleData.entry(now: .now, language: configuration.language.contentLanguage)
    }

    func timeline(for configuration: UpcomingConfigurationIntent, in context: Context) async
        -> Timeline<UpcomingEntry>
    {
        let now = Date.now
        let content: UpcomingContent =
            if let result = await UpcomingLoader.live().load(now: now) {
                .schedule(
                    WidgetSchedule(
                        result: result, language: configuration.language.contentLanguage,
                        interfaceLocale: .current))
            } else {
                .unavailable
            }
        let timeline = UpcomingTimelineBuilder.timeline(for: content, now: now)
        return Timeline(entries: timeline.entries, policy: .after(timeline.reloadDate))
    }
}
