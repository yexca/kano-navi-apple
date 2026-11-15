import KanoNaviCore
import SwiftUI

@main
struct KanoNaviApp: App {
    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    private let services: AppServices
    @State private var dashboard: DashboardStore
    @State private var router: AppRouter
    @State private var notifications: NotificationController

    init() {
        // Reading the configuration here makes a build with a missing or
        // invalid API base URL fail at launch, not on its first request.
        let services = AppServices.live()
        #if os(macOS)
            // A Mac window always shows the tabs in a sidebar, and Settings
            // and About open in windows of their own.
            let router = AppRouter(showsSidebar: true, usesAppWindows: true)
        #else
            let router = AppRouter()
        #endif
        let stream = URLSessionRevisionStream(baseURL: services.client.baseURL)
        let notifications = NotificationController(
            client: services.client,
            calendar: services.calendar
        )
        notifications.installDelegate(router: router)

        self.services = services
        _router = State(initialValue: router)
        _dashboard = State(
            initialValue: DashboardStore(client: services.client, stream: stream)
        )
        _notifications = State(initialValue: notifications)
        #if os(iOS)
            // The delegate seeds the router from the launch's URL or notification
            // while the first scene is configured, before anything is drawn.
            appDelegate.router = router
        #endif
    }

    var body: some Scene {
        #if os(iOS)
            let notifications = notifications
        #endif
        WindowGroup {
            RootView()
                .environment(\.services, services)
                .environment(dashboard)
                .environment(router)
                .environment(notifications)
                #if os(macOS)
                    .frame(minWidth: 720, minHeight: 520)
                    // One window: a link or notification opens in it
                    // instead of in a new one.
                    .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
                #endif
        }
        .commands {
            RefreshCommands()
            #if os(macOS)
                CommandGroup(replacing: .newItem) {}
                AboutCommands()
            #endif
        }
        #if os(iOS)
            .backgroundTask(.appRefresh(notifications.backgroundTaskIdentifier)) {
                await notifications.performBackgroundRefresh()
            }
        #else
            .defaultSize(width: 1100, height: 760)
        #endif

        #if os(macOS)
            // App menu ▸ Settings… (⌘,) opens this window.
            Settings {
                SettingsWindow()
                    .environment(\.services, services)
                    .environment(router)
                    .environment(notifications)
            }

            Window(Text(.More.aboutWindowTitle), id: AboutCommands.windowID) {
                AboutView()
                    .toolbar(removing: .title)
                    .windowMinimizeBehavior(.disabled)
                    .frame(width: 420, height: 420)
            }
            .windowResizability(.contentSize)
            .restorationBehavior(.disabled)
            // App menu ▸ About opens it; the Window menu does not list it.
            .commandsRemoved()
            // A link opens in the main window, never here.
            .handlesExternalEvents(matching: [])
        #endif
    }
}
