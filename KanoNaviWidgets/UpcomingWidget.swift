import SwiftUI
import WidgetKit

/// The calendar widget: what happens next and when, on the Home Screen and
/// the Lock Screen. See `docs/design.md`.
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
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline,
        ])
    }
}
