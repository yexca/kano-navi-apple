import SwiftUI
import WidgetKit

/// The calendar widget: what happens next and when, on the Home Screen and
/// the Lock Screen. See `docs/architecture/widgets.md`.
struct UpcomingWidget: Widget {
    static let kind = "com.yexca.kanonavi.upcoming"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind, intent: UpcomingConfigurationIntent.self, provider: UpcomingProvider()
        ) { entry in
            UpcomingWidgetView(entry: entry)
        }
        .configurationDisplayName(.widgetUpcomingName)
        .description(.widgetUpcomingDescription)
        .supportedFamilies(Self.families)
    }

    /// The Home Screen sizes everywhere, and the Lock Screen layouts on
    /// iPhone and iPad; a Mac has no Lock Screen widgets.
    private static var families: [WidgetFamily] {
        #if os(iOS)
            [
                .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryRectangular,
                .accessoryInline,
            ]
        #else
            [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        #endif
    }
}
