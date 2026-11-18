import Foundation
import KanoNaviCore
import Testing

struct WidgetServerTests {
    let configuration: AppConfiguration

    init() throws {
        configuration = try AppConfiguration(infoDictionary: [
            AppConfiguration.apiBaseURLKey: "https://jp.example.com",
            AppConfiguration.mainlandAPIBaseURLKey: "https://cn.example.com",
        ])
    }

    @Test func defaultsToTheJapanServer() {
        #expect(UpcomingConfigurationIntent().server == .japan)
    }

    @Test(arguments: [
        (WidgetServer.japan, "https://jp.example.com"),
        (.mainlandChina, "https://cn.example.com"),
    ])
    func readsTheConfiguredAddress(choice: WidgetServer, expected: String) {
        #expect(choice.server(in: configuration).baseURL.absoluteString == expected)
    }

    @Test func aServerTheBuildLeavesOutReadsTheDefault() throws {
        let configuration = try AppConfiguration(infoDictionary: [
            AppConfiguration.apiBaseURLKey: "https://jp.example.com"
        ])
        let server = WidgetServer.mainlandChina.server(in: configuration)

        #expect(server.builtIn == .japan)
        #expect(server.baseURL.absoluteString == "https://jp.example.com")
    }
}
