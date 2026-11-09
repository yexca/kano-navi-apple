import SwiftUI
import WidgetKit

/// The upcoming-schedule widget. A placeholder until the calendar timeline
/// exists; see `docs/design.md`.
struct UpcomingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "net.yexca.kanonavi.upcoming", provider: Provider()) { _ in
            Text(.widgetPlaceholder)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(.widgetUpcomingName)
        .description(.widgetUpcomingDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

private struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: .now)], policy: .never))
    }
}

private struct SimpleEntry: TimelineEntry {
    let date: Date
}
