import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowLinkTests {
    @Test(arguments: [
        ("other", NowLink.Destination.site(host: "shop.example.com")),
        ("youtube", .platform(.youtube)),
        ("bilibili", .platform(.bilibili)),
        ("twitch", .site(host: "shop.example.com")),
    ])
    func platformPageDestination(source: String, expected: NowLink.Destination) throws {
        let url = try #require(URL(string: "https://www.shop.example.com/item"))

        #expect(NowLink.page(on: EventPlatform(videoSource: source), url: url).destination == expected)
    }
}
