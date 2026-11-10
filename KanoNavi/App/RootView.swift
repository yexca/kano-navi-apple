import KanoNaviCore
import SwiftUI

/// The app's tab bar. Each tab owns its own navigation stack.
///
/// The dashboard store refreshes only while the scene is active.
struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(DashboardStore.self) private var dashboard
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            Tab(value: AppTab.now) {
                NowView()
            } label: {
                Label {
                    Text(.tabNow)
                } icon: {
                    Image(systemName: "dot.radiowaves.left.and.right")
                }
            }

            Tab(value: AppTab.schedule) {
                ScheduleView()
            } label: {
                Label {
                    Text(.tabSchedule)
                } icon: {
                    Image(systemName: "calendar")
                }
            }

            Tab(value: AppTab.posts) {
                PostsView()
            } label: {
                Label {
                    Text(.tabPosts)
                } icon: {
                    Image(systemName: "text.bubble")
                }
            }

            Tab(value: AppTab.videos) {
                VideosView()
            } label: {
                Label {
                    Text(.tabVideos)
                } icon: {
                    Image(systemName: "play.rectangle")
                }
            }

            Tab(value: AppTab.more) {
                MoreView()
            } label: {
                Label {
                    Text(.tabMore)
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onOpenURL { url in
            router.open(url)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                dashboard.start()
            } else {
                dashboard.stop()
            }
        }
    }
}

#Preview {
    let client = APIClient(
        configuration: .main,
        cache: MemoryResponseCache()
    )
    RootView()
        .environment(DashboardStore(client: client))
        .environment(AppRouter())
}
