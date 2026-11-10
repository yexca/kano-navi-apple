import Foundation
import KanoNaviCore

/// The `kanonavi://` links the widgets open. The app routes both to the
/// Schedule tab.
nonisolated enum WidgetDeepLink {
    static let scheme = "kanonavi"

    /// `kanonavi://event/<id>`, with the ID percent-encoded as a path.
    static func event(_ id: String) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "event"
        components.path = "/" + id
        return components.url ?? schedule(.today)
    }

    /// `kanonavi://schedule?date=<YYYY-MM-DD>`.
    static func schedule(_ date: JapanDate) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "schedule"
        components.queryItems = [URLQueryItem(name: "date", value: date.rawValue)]
        guard let url = components.url else {
            preconditionFailure("A schedule link is always a valid URL")
        }
        return url
    }
}
