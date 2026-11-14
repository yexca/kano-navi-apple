import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowProfileTests {
    private static func resource(_ id: Int, _ url: String) -> [String: Any] {
        ["id": id, "title": "Synthetic \(id)", "url": url]
    }

    @Test func xAccountsComeFromTheLinkDirectoryInItsOrder() throws {
        var fixture = DashboardFixture()
        fixture.resources = [
            Self.resource(1, "https://x.com/synthetic_main"),
            Self.resource(2, "https://shop.example.com/x"),
            Self.resource(3, "https://www.twitter.com/SyntheticSub"),
            Self.resource(4, "https://x.com/synthetic_main"),
        ]

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(profile.xAccounts.map(\.handle) == ["synthetic_main", "SyntheticSub"])
        #expect(
            profile.xAccounts.map(\.url.absoluteString) == [
                "https://x.com/synthetic_main", "https://www.twitter.com/SyntheticSub",
            ])
    }

    @Test(arguments: [
        "https://x.com/synthetic/status/1",
        "https://x.com/",
        "http://x.com/synthetic",
        "https://mobile.x.com/synthetic",
        "https://x.com/synthetic?lang=en",
    ])
    func pagesThatAreNotAnAccountAreLeftOut(url: String) throws {
        let parsed = try #require(URL(string: url))

        #expect(NowProfile.isXAccount(parsed) == false)
    }

    @Test func profileAccountStandsInWhenTheDirectoryHasNone() throws {
        var fixture = DashboardFixture()
        fixture.profile = ["xUrl": "https://x.com/synthetic_profile"]
        fixture.resources = [Self.resource(1, "https://shop.example.com/item")]

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(profile.xAccounts.map(\.handle) == ["synthetic_profile"])
    }

    @Test func bilibiliIsTheDirectorysFirstBilibiliPage() throws {
        var fixture = DashboardFixture()
        fixture.resources = [
            Self.resource(1, "https://www.youtube.com/channel/synthetic"),
            Self.resource(2, "https://space.bilibili.com/1"),
            Self.resource(3, "https://space.bilibili.com/2"),
        ]

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(profile.bilibiliURL?.absoluteString == "https://space.bilibili.com/1")
    }

    @Test func noBilibiliLinkWithoutABilibiliPage() throws {
        var fixture = DashboardFixture()
        fixture.resources = [Self.resource(1, "https://shop.example.com/item")]

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(profile.bilibiliURL == nil)
    }

    @Test func namesAndMediaComeFromTheProfile() throws {
        var fixture = DashboardFixture()
        fixture.profile = [
            "displayName": "合成",
            "romanizedName": "Gousei",
            "avatarUrl": "https://example.com/media/profile/avatar",
        ]

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(profile.displayName == "合成")
        #expect(profile.romanizedName == "Gousei")
        #expect(profile.avatarURL?.absoluteString == "https://example.com/media/profile/avatar")
        #expect(profile.bannerURL == nil)
        #expect(profile.youtubeURL.absoluteString == "https://example.com/youtube")
    }
}
