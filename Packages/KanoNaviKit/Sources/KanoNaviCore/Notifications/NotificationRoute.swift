import Foundation

/// A `kanonavi://` destination opened by widgets and notifications.
public enum NotificationRoute: Equatable, Hashable, Sendable {
    public static let scheme = "kanonavi"

    case now
    case posts
    case videos
    case event(id: String)
    case schedule(date: JapanDate)
    case notificationSettings

    public var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .now:
            components.host = "now"
        case .posts:
            components.host = "posts"
        case .videos:
            components.host = "videos"
        case .event(let id):
            components.host = "event"
            components.path = "/" + id
        case .schedule(let date):
            components.host = "schedule"
            components.queryItems = [URLQueryItem(name: "date", value: date.rawValue)]
        case .notificationSettings:
            components.host = "settings"
            components.path = "/notifications"
        }
        guard let url = components.url else {
            return Self.fallbackScheduleURL()
        }
        return url
    }

    public init?(url: URL, defaultDate: @autoclosure () -> JapanDate = .today) {
        guard url.scheme == Self.scheme else { return nil }
        let pathSegments = url.pathComponents.filter { $0 != "/" }
        switch url.host() {
        case "now":
            guard pathSegments.isEmpty else { return nil }
            self = .now
        case "posts":
            guard pathSegments.isEmpty else { return nil }
            self = .posts
        case "videos":
            guard pathSegments.isEmpty else { return nil }
            self = .videos
        case "event":
            let id = pathSegments.joined(separator: "/")
            guard !id.isEmpty else { return nil }
            self = .event(id: id)
        case "schedule":
            guard pathSegments.isEmpty else { return nil }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let rawDate = components?.queryItems?.first { $0.name == "date" }?.value
            self = .schedule(date: rawDate.flatMap(JapanDate.init(rawValue:)) ?? defaultDate())
        case "settings":
            guard pathSegments == ["notifications"] else { return nil }
            self = .notificationSettings
        default:
            return nil
        }
    }

    private static func fallbackScheduleURL() -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "schedule"
        guard let url = components.url else {
            preconditionFailure("Fallback schedule URL must be valid")
        }
        return url
    }
}
