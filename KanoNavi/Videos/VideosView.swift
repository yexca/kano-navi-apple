import KanoNaviCore
import SwiftUI

/// The Videos tab: the dashboard's video shelf and the month archive. See
/// `docs/design.md`.
///
/// `RootView` starts and stops the dashboard store with the scene; this view
/// only reads it and refreshes it on demand.
struct VideosView: View {
    @Environment(DashboardStore.self) private var dashboard
    @Environment(\.services) private var services

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(.tabVideos)
                .navigationDestination(for: VideosDestination.self) { _ in
                    if let services {
                        VideoArchiveScreen(client: services.client)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot = dashboard.snapshot {
            VideoShelfList(
                shelf: VideoShelf(dashboard: snapshot), dashboard: dashboard, showsArchive: services != nil
            )
            .refreshable(action: dashboard.refresh)
        } else {
            DashboardUnavailableView(dashboard: dashboard) {
                if services != nil {
                    NavigationLink(value: VideosDestination.archive) {
                        Text(.Videos.pastVideos)
                    }
                }
            }
        }
    }
}

#Preview {
    VideosView()
        .environment(DashboardStore(client: APIClient(configuration: .main, cache: MemoryResponseCache())))
}
