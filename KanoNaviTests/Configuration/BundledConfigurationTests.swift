import Foundation
import Testing

/// Guards the build wiring: `//` starts an xcconfig comment, so a mistyped
/// `API_BASE_URL` reaches the app's Info.plist cut short or empty.
struct BundledConfigurationTests {
    @Test func appBundleHasHTTPSBaseURL() throws {
        let rawValue = try #require(Bundle.main.object(forInfoDictionaryKey: "KanoNaviAPIBaseURL") as? String)
        let url = try #require(URL(string: rawValue))

        #expect(url.scheme == "https")
        #expect(url.host()?.isEmpty == false)
    }
}
