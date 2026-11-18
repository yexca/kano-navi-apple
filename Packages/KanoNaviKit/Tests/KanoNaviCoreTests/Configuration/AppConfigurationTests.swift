import Foundation
import Testing

@testable import KanoNaviCore

struct AppConfigurationTests {
    @Test func readsHTTPSBaseURL() throws {
        let configuration = try AppConfiguration(
            infoDictionary: [AppConfiguration.apiBaseURLKey: "https://api.example.com"]
        )

        #expect(configuration.apiBaseURL == URL(string: "https://api.example.com"))
    }

    @Test func listsTheBuiltInServersTheBuildSets() throws {
        let configuration = try AppConfiguration(infoDictionary: [
            AppConfiguration.apiBaseURLKey: "https://jp.example.com",
            AppConfiguration.mainlandAPIBaseURLKey: "https://cn.example.com",
        ])

        #expect(configuration.builtInServers.map(\.id) == ["japan", "mainlandChina"])
        #expect(configuration.mainlandAPIBaseURL == URL(string: "https://cn.example.com"))
    }

    @Test(arguments: [[:], [AppConfiguration.mainlandAPIBaseURLKey: ""]])
    func aBuildWithoutTheMainlandServerListsOnlyTheDefault(extra: [String: String]) throws {
        var info = extra
        info[AppConfiguration.apiBaseURLKey] = "https://jp.example.com"
        let configuration = try AppConfiguration(infoDictionary: info)

        #expect(configuration.mainlandAPIBaseURL == nil)
        #expect(configuration.builtInServers.map(\.id) == ["japan"])
    }

    @Test func rejectsAMainlandServerWithoutHTTPS() {
        #expect(throws: AppConfigurationError.invalidAPIBaseURL("http://cn.example.com")) {
            try AppConfiguration(infoDictionary: [
                AppConfiguration.apiBaseURLKey: "https://jp.example.com",
                AppConfiguration.mainlandAPIBaseURLKey: "http://cn.example.com",
            ])
        }
    }

    @Test func rejectsMissingBaseURL() {
        #expect(throws: AppConfigurationError.missingAPIBaseURL) {
            try AppConfiguration(infoDictionary: [:])
        }
    }

    @Test(arguments: [
        "",
        "http://api.example.com",
        "api.example.com",
        "https://",
        "ftp://api.example.com",
    ])
    func rejectsBaseURLWithoutHTTPSAndHost(rawValue: String) {
        #expect(throws: AppConfigurationError.invalidAPIBaseURL(rawValue)) {
            try AppConfiguration(infoDictionary: [AppConfiguration.apiBaseURLKey: rawValue])
        }
    }
}
