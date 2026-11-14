import KanoNaviCore
import SwiftUI

/// The Videos tab: one timeline of every dated video, newest first, with the
/// kind and platform filter at the leading end of the navigation bar and the
/// month jump at its trailing end. See `docs/design.md`.
struct VideosView: View {
    @Environment(\.services) private var services

    var body: some View {
        NavigationStack {
            if let services {
                VideoTimelineScreen(client: services.client)
            }
        }
    }
}

#Preview {
    let client = APIClient(configuration: .main, cache: MemoryResponseCache())
    VideosView()
        .environment(\.services, AppServices(client: client, calendar: CalendarReader(client: client)))
}
