import AppIntents
import WidgetKit

/// The Upcoming widget's settings.
struct UpcomingConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widgetIntentTitle"
    static let description = IntentDescription("widgetIntentDescription")

    @Parameter(title: "widgetIntentLanguage", default: .sameAsApp)
    var language: WidgetContentLanguage

    @Parameter(title: "widgetIntentServer", default: .japan)
    var server: WidgetServer

    init() {}

    init(language: WidgetContentLanguage, server: WidgetServer = .japan) {
        self.language = language
        self.server = server
    }
}
