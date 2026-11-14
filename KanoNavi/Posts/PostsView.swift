import KanoNaviCore
import SwiftUI

/// The Posts tab: the dashboard's recent posts, with the account filter at
/// the leading end of the navigation bar and Past Posts, the month archive,
/// at its trailing end. See `docs/design.md`.
///
/// `RootView` starts and stops the dashboard store with the scene; this view
/// only reads it and refreshes it on demand.
struct PostsView: View {
    @Environment(DashboardStore.self) private var dashboard
    @Environment(\.services) private var services

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(.tabPosts)
                .toolbar {
                    if services != nil {
                        ToolbarItem(placement: .primaryAction) {
                            NavigationLink(value: PostsDestination.archive) {
                                Label {
                                    Text(.Posts.pastPosts)
                                } icon: {
                                    Image(systemName: "clock.arrow.circlepath")
                                }
                            }
                            .accessibilityIdentifier("posts.archive")
                        }
                    }
                }
                .navigationDestination(for: PostsDestination.self) { _ in
                    if let services {
                        PostArchiveScreen(
                            client: services.client, meta: dashboard.snapshot?.meta,
                            accountAvatars: dashboard.snapshot?.accountAvatars,
                            profileAvatarURL: dashboard.snapshot?.profile.avatarURL)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot = dashboard.snapshot {
            PostsList(snapshot: snapshot, dashboard: dashboard)
        } else {
            DashboardUnavailableView(dashboard: dashboard) {}
        }
    }
}

#Preview {
    PostsView()
        .environment(DashboardStore(client: APIClient(configuration: .main, cache: MemoryResponseCache())))
}
