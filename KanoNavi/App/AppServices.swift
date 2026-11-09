import KanoNaviCore
import SwiftUI

/// The app's shared, long-lived data services. Screens read them from the
/// environment instead of building their own clients.
struct AppServices {
    let client: APIClient
    let calendar: CalendarReader

    /// Services for the running app, reading the API base URL from Info.plist
    /// and caching responses in the app's caches directory.
    static func live() -> AppServices {
        let client = APIClient(
            configuration: .main,
            cache: FileResponseCache(directory: FileResponseCache.defaultDirectory(named: "KanoNavi"))
        )
        return AppServices(client: client, calendar: CalendarReader(client: client))
    }
}

extension EnvironmentValues {
    /// The app's data services; `nil` only in previews that do not set them.
    @Entry var services: AppServices?
}
