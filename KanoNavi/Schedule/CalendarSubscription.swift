import Foundation
import KanoNaviCore

/// Links to the service's iCalendar feed in the interface language.
nonisolated enum CalendarSubscription {
    /// The feed's HTTPS URL with `lang` set for the interface language:
    /// `en`, `ja` or `zh-CN`.
    static func feedURL(from feed: URL, interfaceLocale: Locale) -> URL? {
        guard var components = URLComponents(url: feed, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var items = components.queryItems ?? []
        items.removeAll { $0.name == "lang" }
        items.append(
            URLQueryItem(name: "lang", value: ContentLocale(interfaceLocale: interfaceLocale).apiLocale))
        components.queryItems = items
        return components.url
    }

    /// The `webcal://` form of ``feedURL(from:interfaceLocale:)``, which the
    /// Calendar app offers to subscribe to.
    static func webcalURL(from feed: URL, interfaceLocale: Locale) -> URL? {
        guard let url = feedURL(from: feed, interfaceLocale: interfaceLocale),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }
        components.scheme = "webcal"
        return components.url
    }
}
