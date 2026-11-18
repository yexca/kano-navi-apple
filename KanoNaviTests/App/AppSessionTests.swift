import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct AppSessionTests {
    let defaults: UserDefaults
    let configuration: AppConfiguration
    let stateStore = MemoryNotificationStateStore()

    init() throws {
        let suiteName = "com.yexca.kanonavi.tests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        configuration = try AppConfiguration(infoDictionary: [
            AppConfiguration.apiBaseURLKey: "https://jp.example.com",
            AppConfiguration.mainlandAPIBaseURLKey: "https://cn.example.com",
        ])
    }

    private func makeSession() -> AppSession {
        AppSession(configuration: configuration, store: ServerListStore(defaults: defaults)) {
            [defaults, stateStore] services in
            NotificationController(
                client: services.client,
                calendar: services.calendar,
                stateStore: stateStore,
                preferencesStore: NotificationPreferencesStore(defaults: defaults),
                center: MockUserNotificationCenterClient(status: .authorized),
                backgroundScheduler: MockBackgroundRefreshScheduler(),
                defaults: defaults
            )
        }
    }

    private func url(_ string: String) throws -> URL {
        try #require(URL(string: string))
    }

    @Test func readsTheDefaultServerAtFirst() {
        let session = makeSession()

        #expect(session.servers.selected.builtIn == .japan)
        #expect(session.services.client.baseURL.absoluteString == "https://jp.example.com")
    }

    @Test func selectingAServerBuildsItsServicesAndStore() {
        let session = makeSession()
        let firstDashboard = session.dashboard

        session.select(BuiltInServer.mainlandChina.rawValue)

        #expect(session.services.client.baseURL.absoluteString == "https://cn.example.com")
        #expect(session.dashboard !== firstDashboard)
    }

    @Test func selectingTheSelectedServerKeepsItsStore() {
        let session = makeSession()
        let firstDashboard = session.dashboard

        session.select(BuiltInServer.japan.rawValue)

        #expect(session.dashboard === firstDashboard)
    }

    @Test func theSelectionAndAddedServersOutliveTheSession() throws {
        let session = makeSession()
        try session.add(name: "Home", baseURL: url("https://home.example.org"))

        let next = makeSession()

        #expect(next.servers.custom.map(\.name) == ["Home"])
        #expect(next.servers.selected.name == "Home")
        #expect(next.services.client.baseURL.absoluteString == "https://home.example.org")
    }

    @Test func removingTheSelectedServerReadsTheDefault() throws {
        let session = makeSession()
        try session.add(name: "Home", baseURL: url("https://home.example.org"))
        let added = session.servers.selected

        session.remove(added.id)

        #expect(session.servers.custom.isEmpty)
        #expect(session.services.client.baseURL.absoluteString == "https://jp.example.com")
    }

    @Test func switchingDropsTheNotificationBaseline() async throws {
        let session = makeSession()
        await stateStore.save(NotificationBaseline(establishedAt: .now, lastRevision: 1))

        session.select(BuiltInServer.mainlandChina.rawValue)
        await session.notifications.finishServiceSwitch()

        #expect(await stateStore.load() == nil)
    }
}
