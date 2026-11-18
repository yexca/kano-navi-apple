import KanoNaviCore
import SwiftUI

/// The app's shared, long-lived data services for one server. Screens read
/// them from the environment instead of building their own clients.
struct AppServices {
    let client: APIClient
    let calendar: CalendarReader

    /// Services for the running app, reading `server` and caching responses
    /// in the app's caches directory. Cached responses are keyed by URL, so
    /// each server keeps its own.
    static func live(server: ServiceServer) -> AppServices {
        let client = APIClient(
            server: server,
            cache: FileResponseCache(directory: FileResponseCache.defaultDirectory(named: "KanoNavi"))
        )
        return AppServices(client: client, calendar: CalendarReader(client: client))
    }
}

extension EnvironmentValues {
    /// The app's data services; `nil` only in previews that do not set them.
    @Entry var services: AppServices?
}
