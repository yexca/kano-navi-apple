import AppIntents
import Foundation
import KanoNaviCore

/// The built-in server a widget reads. The widget cannot read the app's
/// server setting without an App Group, so each widget chooses its own, and
/// servers added in the app are not offered.
nonisolated enum WidgetServer: String, AppEnum {
    case japan
    case mainlandChina

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widgetServerType"

    static let caseDisplayRepresentations: [WidgetServer: DisplayRepresentation] = [
        .japan: "widgetServerJapan",
        .mainlandChina: "widgetServerMainlandChina",
    ]

    var builtIn: BuiltInServer {
        switch self {
        case .japan: .japan
        case .mainlandChina: .mainlandChina
        }
    }

    /// The server as the build configures it; the default server when the
    /// build sets no address for this one.
    func server(in configuration: AppConfiguration) -> ServiceServer {
        if let baseURL = configuration.baseURL(of: builtIn) {
            return ServiceServer(builtIn: builtIn, baseURL: baseURL)
        }
        return ServiceServer(builtIn: .japan, baseURL: configuration.apiBaseURL)
    }
}
