import SwiftUI
import WidgetKit

/// Chooses the Upcoming layout for the widget's family.
struct UpcomingWidgetView: View {
    let entry: UpcomingEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallUpcomingView(entry: entry)
                .widgetURL(singleEntryURL)
                .containerBackground(.background, for: .widget)
        case .systemMedium:
            MediumUpcomingView(entry: entry)
                .widgetURL(entry.scheduleURL)
                .containerBackground(.background, for: .widget)
        case .accessoryRectangular:
            RectangularUpcomingView(entry: entry)
                .widgetURL(singleEntryURL)
                .containerBackground(.clear, for: .widget)
        case .accessoryInline:
            InlineUpcomingView(entry: entry)
                .widgetURL(singleEntryURL)
                .containerBackground(.clear, for: .widget)
        default:
            LargeUpcomingView(entry: entry)
                .widgetURL(entry.scheduleURL)
                .containerBackground(.background, for: .widget)
        }
    }

    /// The shown entry for single-entry layouts, which have no separate
    /// tap targets, or the schedule when there is none.
    private var singleEntryURL: URL {
        entry.schedule?.next(at: entry.date)?.url ?? entry.scheduleURL
    }
}
