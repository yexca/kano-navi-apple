import KanoNaviCore
import SwiftUI

/// The Posts tab: the dashboard's recent posts and the month archive. See
/// `docs/design.md`.
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
                .navigationDestination(for: PostsDestination.self) { _ in
                    if let services {
                        PostArchiveScreen(client: services.client, meta: dashboard.snapshot?.meta)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot = dashboard.snapshot {
            PostsList(snapshot: snapshot, dashboard: dashboard, showsArchive: services != nil)
        } else {
            DashboardUnavailableView(dashboard: dashboard) {
                if services != nil {
                    NavigationLink(value: PostsDestination.archive) {
                        Text(.Posts.pastPosts)
                    }
                }
            }
        }
    }
}

#Preview {
    PostsView()
        .environment(DashboardStore(client: APIClient(configuration: .main, cache: MemoryResponseCache())))
}
