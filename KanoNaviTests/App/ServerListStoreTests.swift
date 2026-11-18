import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct ServerListStoreTests {
    let defaults: UserDefaults
    let builtIn: [ServiceServer]

    init() throws {
        let suiteName = "com.yexca.kanonavi.tests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        builtIn = [
            ServiceServer(builtIn: .japan, baseURL: try #require(URL(string: "https://jp.example.com")))
        ]
    }

    @Test func nothingSavedLoadsTheBuiltInServers() {
        let list = ServerListStore(defaults: defaults).load(builtIn: builtIn)
        #expect(list == ServerList(builtIn: builtIn))
    }

    @Test func savedServersAndSelectionLoadAgain() throws {
        let store = ServerListStore(defaults: defaults)
        var list = ServerList(builtIn: builtIn)
        let added = try list.add(name: "Home", baseURL: try #require(URL(string: "https://home.example.org")))
        list.select(added.id)

        store.save(list)

        #expect(store.load(builtIn: builtIn) == list)
    }

    @Test func unreadableSavedServersAreDropped() {
        defaults.set(Data("not json".utf8), forKey: AppSettings.customServersKey)
        defaults.set("custom-gone", forKey: AppSettings.selectedServerKey)

        let list = ServerListStore(defaults: defaults).load(builtIn: builtIn)

        #expect(list.custom.isEmpty)
        #expect(list.selected == builtIn[0])
    }
}
