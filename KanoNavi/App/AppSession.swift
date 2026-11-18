import Foundation
import KanoNaviCore
import Observation

/// The servers the app can read and the services for the selected one.
///
/// Selecting another server builds new services and a new dashboard store
/// for it, and points notifications at it. The screens that read the
/// services start over with the new server's saved copy.
@Observable
final class AppSession {
    private(set) var servers: ServerList
    private(set) var services: AppServices
    private(set) var dashboard: DashboardStore
    let notifications: NotificationController

    @ObservationIgnored private let store: ServerListStore

    /// - Parameter makeNotifications: Builds the notification controller for
    ///   the first server's services.
    init(
        configuration: AppConfiguration = .main,
        store: ServerListStore = ServerListStore(),
        makeNotifications: (AppServices) -> NotificationController = {
            NotificationController(client: $0.client, calendar: $0.calendar)
        }
    ) {
        let servers = store.load(builtIn: configuration.builtInServers)
        let services = AppServices.live(server: servers.selected)
        self.servers = servers
        self.services = services
        self.dashboard = Self.makeDashboard(for: services)
        self.notifications = makeNotifications(services)
        self.store = store
    }

    /// Reads a listed server instead of the selected one.
    func select(_ id: ServiceServer.ID) {
        let previous = servers.selectedID
        servers.select(id)
        guard servers.selectedID != previous else { return }
        store.save(servers)
        connect()
    }

    /// Adds a server and reads it.
    func add(name: String, baseURL: URL) throws(ServerListError) {
        let server = try servers.add(name: name, baseURL: baseURL)
        servers.select(server.id)
        store.save(servers)
        connect()
    }

    /// Removes a server the person added. Removing the selected one reads
    /// the default server.
    func remove(_ id: ServiceServer.ID) {
        let previous = servers.selectedID
        servers.remove(id)
        store.save(servers)
        if servers.selectedID != previous {
            connect()
        }
    }

    private func connect() {
        dashboard.stop()
        services = AppServices.live(server: servers.selected)
        dashboard = Self.makeDashboard(for: services)
        notifications.switchService(client: services.client, calendar: services.calendar)
    }

    private static func makeDashboard(for services: AppServices) -> DashboardStore {
        DashboardStore(
            client: services.client,
            stream: URLSessionRevisionStream(baseURL: services.client.baseURL)
        )
    }
}
