import Foundation
import KanoNaviCore

/// Reads the widget's calendar range from the service, falling back to the
/// extension's own cache.
nonisolated struct UpcomingLoader: Sendable {
    let client: APIClient

    /// The loader for the running extension, reading `server` and caching in
    /// its own container. Cached responses are keyed by URL, so each server
    /// keeps its own.
    static func live(server: WidgetServer) -> UpcomingLoader {
        UpcomingLoader(
            client: APIClient(
                server: server.server(in: .main),
                cache: FileResponseCache(
                    directory: FileResponseCache.defaultDirectory(named: "KanoNaviWidgets"))
            ))
    }

    /// Today through 13 days ahead, in Japan dates. A failed read returns the
    /// cached range marked stale with its fetch time; returns `nil` when the
    /// read fails and nothing is cached.
    func load(now: Date) async -> WidgetCalendarResult? {
        try? await CalendarReader(client: client).widgetRange(today: JapanDate.date(from: now), now: now)
    }
}
