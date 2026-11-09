import KanoNaviCore
import SwiftUI

@main
struct KanoNaviApp: App {
    private let services: AppServices
    @State private var dashboard: DashboardStore
    @State private var router = AppRouter()

    init() {
        // Reading the configuration here makes a build with a missing or
        // invalid API base URL fail at launch, not on its first request.
        let services = AppServices.live()
        self.services = services
        _dashboard = State(initialValue: DashboardStore(client: services.client))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.services, services)
                .environment(dashboard)
                .environment(router)
        }
    }
}
