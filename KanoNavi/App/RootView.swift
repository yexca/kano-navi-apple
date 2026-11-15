import KanoNaviCore
import SwiftUI

/// The app's tabs: a tab bar on iPhone, a sidebar on Mac, and on iPad a tab
/// bar that the person can turn into a sidebar. A tab bar shows Now,
/// Schedule, Posts, Videos and More; a sidebar shows the first four, then
/// More's screens as tabs in two sections. Each tab owns its own navigation
/// stack.
///
/// The dashboard store refreshes only while the scene is active. Timed
/// reminders are rebuilt from a fresh calendar read when the scene becomes
/// active or enters the background, where the next background refresh is also
/// scheduled if enabled.
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
                    .reportsTabPresentation()
            } label: {
                Label {
                    Text(.tabNow)
                } icon: {
                    Image(systemName: "dot.radiowaves.left.and.right")
                }
            }

            Tab(value: AppTab.schedule) {
                ScheduleView()
                    .reportsTabPresentation()
            } label: {
                Label {
                    Text(.tabSchedule)
                } icon: {
                    Image(systemName: "calendar")
                }
            }

            Tab(value: AppTab.posts) {
                PostsView()
                    .reportsTabPresentation()
            } label: {
                Label {
                    Text(.tabPosts)
                } icon: {
                    Image(systemName: "text.bubble")
                }
            }

            Tab(value: AppTab.videos) {
                VideosView()
                    .reportsTabPresentation()
            } label: {
                Label {
                    Text(.tabVideos)
                } icon: {
                    Image(systemName: "play.rectangle")
                }
            }

            // A sidebar lists More's screens as tabs of their own; a tab bar
            // reaches them through More. The list is built from the reported
            // presentation rather than with `defaultVisibility`, because an
            // iPad's bar at the top shows only tabs its sidebar lists.
            // `AppRouter` moves the selection when an iPad switches.
            if router.showsSidebar == true {
                TabSection {
                    ForEach(MoreItem.archives) { item in
                        moreItemTab(item)
                    }
                } header: {
                    Text(.sidebarArchive)
                }

                TabSection {
                    ForEach(MoreItem.app) { item in
                        moreItemTab(item)
                    }
                } header: {
                    Text(.sidebarApp)
                }
            } else {
                Tab(value: AppTab.more) {
                    MoreView()
                        .reportsTabPresentation()
                } label: {
                    Label {
                        Text(.tabMore)
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onOpenURL { url in
            router.open(url)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active:
                dashboard.start()
                Task {
                    await notifications?.refreshSystemStatus()
                    await notifications?.refreshReminders(interfaceLocale: locale)
                }
            case .background:
                dashboard.stop()
                router.forgetLaunchRoute()
                Task {
                    await notifications?.handleDidEnterBackground(interfaceLocale: locale)
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

    private func moreItemTab(_ item: MoreItem) -> some TabContent<AppTab> {
        Tab(value: item.tab) {
            MoreItemTab(item: item)
                .reportsTabPresentation()
        } label: {
            item.label
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
