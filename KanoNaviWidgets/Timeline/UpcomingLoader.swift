import Foundation
import KanoNaviCore

/// Reads the widget's calendar range from the service, falling back to the
/// extension's own cache.
nonisolated struct UpcomingLoader: Sendable {
    let client: APIClient

    /// The loader for the running extension, caching in its own container.
    static func live() -> UpcomingLoader {
        UpcomingLoader(
            client: APIClient(
                configuration: .main,
                cache: FileResponseCache(
                    directory: FileResponseCache.defaultDirectory(named: "KanoNaviWidgets"))
            ))
    }

    /// Today through 13 days ahead, in Japan dates. Returns `nil` when the
    /// read fails and nothing is cached.
    func load(now: Date) async -> WidgetCalendarResult? {
        let today = JapanDate.date(from: now)
        let startedAt = Date.now
        guard var result = try? await CalendarReader(client: client).widgetRange(today: today, now: now)
        else { return nil }
        // `CalendarReader.read` falls back to cached pages without saying so.
        // A first page cached before this read began means the read failed.
        let cachedAt = await client.cachedFetchedAt(CalendarRequest(from: today, to: today.addingDays(13)))
        if let cachedAt, cachedAt < startedAt {
            result.isStale = true
            result.fetchedAt = cachedAt
        } else if result.isStale, result.fetchedAt == nil {
            result.fetchedAt = cachedAt
        }
        return result
    }
}
