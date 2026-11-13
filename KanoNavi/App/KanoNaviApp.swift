import KanoNaviCore
import SwiftUI

@main
struct KanoNaviApp: App {
    private let services: AppServices
    @State private var dashboard: DashboardStore
    @State private var router: AppRouter
    @State private var notifications: NotificationController

    init() {
        // Reading the configuration here makes a build with a missing or
        // invalid API base URL fail at launch, not on its first request.
        let services = AppServices.live()
        let router = AppRouter()
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
    }

    var body: some Scene {
        let notifications = notifications
        WindowGroup {
            RootView()
                .environment(\.services, services)
                .environment(dashboard)
                .environment(router)
                .environment(notifications)
        }
        .backgroundTask(.appRefresh(notifications.backgroundTaskIdentifier)) {
            await notifications.performBackgroundRefresh()
        }
    }
}
