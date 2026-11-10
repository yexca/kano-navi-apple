import AppIntents
import WidgetKit

/// The Upcoming widget's settings.
struct UpcomingConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widgetIntentTitle"
    static let description = IntentDescription("widgetIntentDescription")

    @Parameter(title: "widgetIntentLanguage", default: .sameAsApp)
    var language: WidgetContentLanguage

    init() {}

    init(language: WidgetContentLanguage) {
        self.language = language
    }
}
