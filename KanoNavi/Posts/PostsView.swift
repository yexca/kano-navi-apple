import KanoNaviCore
import SwiftUI

/// The Posts tab: one timeline of every post, newest first, with the account
/// filter at the leading end of the navigation bar and the month picker at
/// its trailing end. See `docs/architecture/board-and-timelines.md`.
///
/// The dashboard gives the accounts the filter offers, the avatars a page
/// leaves out and the data revision that makes the timeline read its pages
/// again. `RootView` starts and stops the dashboard store with the scene;
/// this view only reads it.
struct PostsView: View {
    @Environment(DashboardStore.self) private var dashboard
    @Environment(\.services) private var services

    var body: some View {
        NavigationStack {
            if let services {
                let snapshot = dashboard.snapshot
                let avatars = PostAvatarFallback(
                    accountAvatars: snapshot?.accountAvatars, profileAvatarURL: snapshot?.profile.avatarURL)
                PostTimelineScreen(
                    client: services.client, meta: snapshot?.meta, revision: snapshot?.meta.revision,
                    avatarFallback: avatars)
            }
        }
        // Another server starts the timeline and its stack over.
        .id(services?.client.baseURL)
    }
}

#Preview {
    let client = APIClient(configuration: .main, cache: MemoryResponseCache())
    PostsView()
        .environment(DashboardStore(client: client))
        .environment(\.services, AppServices(client: client, calendar: CalendarReader(client: client)))
}
