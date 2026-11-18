import Foundation
import Testing

@testable import KanoNaviCore

struct ServerListTests {
    let japan: ServiceServer
    let mainland: ServiceServer

    init() throws {
        japan = ServiceServer(builtIn: .japan, baseURL: try #require(URL(string: "https://jp.example.com")))
        mainland = ServiceServer(
            builtIn: .mainlandChina, baseURL: try #require(URL(string: "https://cn.example.com")))
    }

    private func url(_ string: String) throws -> URL {
        try #require(URL(string: string))
    }

    @Test func selectsTheDefaultWithoutASavedSelection() {
        let list = ServerList(builtIn: [japan, mainland])
        #expect(list.selected == japan)
    }

    @Test func keepsASavedSelection() {
        let list = ServerList(builtIn: [japan, mainland], selectedID: mainland.id)
        #expect(list.selected == mainland)
    }

    @Test func anUnknownSavedSelectionSelectsTheDefault() {
        let list = ServerList(builtIn: [japan, mainland], selectedID: "custom-gone")
        #expect(list.selected == japan)
    }

    @Test func addsAServerAfterTheBuiltInOnes() throws {
        var list = ServerList(builtIn: [japan, mainland])
        let added = try list.add(name: "  Home  ", baseURL: url("https://home.example.org"))

        #expect(added.name == "Home")
        #expect(added.builtIn == nil)
        #expect(list.all.map(\.id) == [japan.id, mainland.id, added.id])
    }

    @Test func anUnnamedServerIsNamedForItsAddress() throws {
        var list = ServerList(builtIn: [japan])
        let added = try list.add(name: " ", baseURL: url("https://example.org/kano"))
        #expect(added.name == "example.org/kano")
    }

    @Test func refusesAnAddressAlreadyListed() throws {
        var list = ServerList(builtIn: [japan, mainland])
        #expect(throws: ServerListError.duplicate(mainland.id)) {
            try list.add(name: "Copy", baseURL: mainland.baseURL)
        }
    }

    @Test func savedServersRepeatingAnAddressAreDropped() throws {
        let copy = ServiceServer.custom(name: "Copy", baseURL: japan.baseURL)
        let home = ServiceServer.custom(name: "Home", baseURL: try url("https://home.example.org"))
        let list = ServerList(builtIn: [japan], custom: [copy, home, home])
        #expect(list.custom == [home])
    }

    @Test func removingTheSelectedServerSelectsTheDefault() throws {
        var list = ServerList(builtIn: [japan, mainland])
        let added = try list.add(name: "Home", baseURL: url("https://home.example.org"))
        list.select(added.id)

        list.remove(added.id)

        #expect(list.custom.isEmpty)
        #expect(list.selected == japan)
    }

    @Test func aBuiltInServerCannotBeRemoved() {
        var list = ServerList(builtIn: [japan, mainland], selectedID: mainland.id)
        list.remove(mainland.id)
        #expect(list.all == [japan, mainland])
    }
}
