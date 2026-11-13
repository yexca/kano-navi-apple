import KanoNaviCore
import SwiftUI

/// The app's tab bar. Each tab owns its own navigation stack.
///
/// The dashboard store refreshes only while the scene is active; when the scene
/// enters the background, local notification refresh is scheduled if enabled.
struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(DashboardStore.self) private var dashboard
    @Environment(NotificationController.self) private var notifications: NotificationController?
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system

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
            switch phase {
            case .active:
                dashboard.start()
                Task {
                    await notifications?.refreshSystemStatus()
                }
            case .background:
                dashboard.stop()
                Task {
                    await notifications?.handleDidEnterBackground()
                }
            case .inactive:
                dashboard.stop()
            @unknown default:
                dashboard.stop()
            }
        }
        .onChange(of: dashboard.snapshot, initial: true) { _, snapshot in
            guard let snapshot else { return }
            Task {
                await notifications?.observeForegroundSnapshot(snapshot, interfaceLocale: locale)
            }
        }
        .onChange(of: contentLanguage) { _, _ in
            Task {
                await notifications?.handleLanguageChange(interfaceLocale: locale)
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
