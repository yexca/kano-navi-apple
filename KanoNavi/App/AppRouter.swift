import Foundation
import KanoNaviCore
import Observation

/// The selected tab and pending deep-link targets.
///
/// The widgets open `kanonavi://event/<id>` and
/// `kanonavi://schedule?date=<YYYY-MM-DD>`; both select the Schedule tab and
/// leave a ``ScheduleFocus`` for it to consume.
@Observable
final class AppRouter {
    var selectedTab = AppTab.now
    var scheduleFocus: ScheduleFocus?

    /// Applies a `kanonavi://` URL. Returns `false` for any other URL.
    @discardableResult
    func open(_ url: URL) -> Bool {
        guard let focus = Self.scheduleFocus(for: url) else { return false }
        selectedTab = .schedule
        scheduleFocus = focus
        return true
    }

    /// The schedule target a `kanonavi://` URL names, if any. A schedule link
    /// without a valid date focuses today's Japan date.
    static func scheduleFocus(for url: URL) -> ScheduleFocus? {
        guard url.scheme == "kanonavi" else { return nil }
        switch url.host() {
        case "event":
            let id = url.pathComponents.dropFirst().joined(separator: "/")
            return id.isEmpty ? nil : .event(id: id)
        case "schedule":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let rawDate = components?.queryItems?.first { $0.name == "date" }?.value
            return .date(rawDate.flatMap(JapanDate.init(rawValue:)) ?? .today)
        default:
            return nil
        }
    }
}
