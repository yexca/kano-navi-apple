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
