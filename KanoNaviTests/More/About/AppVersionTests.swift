import Testing

@testable import KanoNavi

@MainActor
struct AppVersionTests {
    @Test(
        arguments: [
            (["CFBundleShortVersionString": "1.2", "CFBundleVersion": "34"], "1.2 (34)"),
            (["CFBundleShortVersionString": "1.2", "CFBundleVersion": "1.2"], "1.2"),
            (["CFBundleShortVersionString": "1.2"], "1.2"),
            (["CFBundleVersion": "34"], "34"),
            ([:], "—"),
        ] as [([String: String], String)])
    func displayString(info: [String: String], expected: String) {
        #expect(AppVersion(infoDictionary: info).displayString == expected)
    }

    @Test func runningAppHasAVersion() {
        #expect(AppVersion.main.version?.isEmpty == false)
    }
}
