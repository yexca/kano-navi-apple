import Foundation
import Testing

@testable import KanoNavi

@MainActor
struct AppIconTests {
    /// The build writes the primary icon into Info.plist only when the
    /// `AppIcon` set in the asset catalog has an image for the platform.
    @Test func appHasThePrimaryIconFromTheAssetCatalog() throws {
        #if os(iOS)
            let icons = try #require(Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any])
            let primary = try #require(icons["CFBundlePrimaryIcon"] as? [String: Any])
            #expect(primary["CFBundleIconName"] as? String == "AppIcon")
        #else
            #expect(Bundle.main.infoDictionary?["CFBundleIconName"] as? String == "AppIcon")
        #endif
    }
}
