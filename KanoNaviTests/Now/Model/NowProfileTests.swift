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

    @Test func countsComeFromTheSummaryWithThePostWindow() throws {
        var fixture = DashboardFixture()
        fixture.counts = ["upcomingEvents": 12, "posts": 34, "videos": 5]
        fixture.postWindowDays = 3

        let profile = NowProfile(dashboard: try fixture.dashboard())

        #expect(
            profile.counts
                == NowProfile.Counts(upcomingEvents: 12, posts: 34, postWindowDays: 3, videos: 5))
    }

    @Test func noCountsWithoutSummaryCounts() throws {
        let profile = NowProfile(dashboard: try DashboardFixture().dashboard())

        #expect(profile.counts == nil)
    }

    @Test func videosCountTheAPIsSevenDayWindow() {
        #expect(NowProfile.Counts.videoWindowDays == 7)
    }

    @Test func countLabelsArePluralizedInEachLanguage() {
        #expect(resolved(.Now.profileUpcomingCount(1), "en") == "1 upcoming entry")
        #expect(resolved(.Now.profileUpcomingCount(12), "en") == "12 upcoming entries")
        #expect(resolved(.Now.profilePostCount(count: 1, days: 1), "en") == "1 post in 1 day")
        #expect(resolved(.Now.profilePostCount(count: 34, days: 3), "en") == "34 posts in 3 days")
        #expect(resolved(.Now.profileVideoCount(count: 5, days: 7), "en") == "5 videos in 7 days")
        #expect(resolved(.Now.profilePostCount(count: 34, days: 3), "ja") == "3 日間のポスト 34 件")
        #expect(resolved(.Now.profileVideoCount(count: 5, days: 7), "zh-Hans") == "7 天内视频 5 个")
    }

    @Test(arguments: ["en", "ja", "zh-Hans"])
    func taglineAndCatchphraseAreTheSameInEveryLanguage(language: String) {
        #expect(resolved(.Now.profileTagline, language) == "Virtual Artist · ミリプロ SONA")
        #expect(resolved(.Now.profileCatchphrase, language) == "みんなの毎日を、まほろばに。")
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
