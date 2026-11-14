import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostRecentFilterTests {
    @Test func choicesAreTheXAccountsThenOneBilibiliWithRecentCounts() throws {
        let (meta, cards) = try Self.recent()

        let options = PostRecentFilter.options(cards: cards, accounts: PostRecentFilter.accounts(meta: meta))

        #expect(options.map(\.code) == [nil, "Kano_Example", "_Sub", PostRecentFilter.bilibiliCode])
        #expect(options.map(\.count) == [5, 2, 1, 1])
        #expect(options[1].label == .verbatim("@Kano_Example"))
        #expect(options.map(\.logo) == [nil, .x, .x, .bilibili])
    }

    @Test func withoutABilibiliAccountThereIsNoBilibiliChoice() throws {
        var fixture = DashboardFixture()
        fixture.xAccounts = ["@Kano_Example"]
        fixture.bilibiliAccounts = []

        let accounts = PostRecentFilter.accounts(meta: try fixture.dashboard().meta)

        #expect(accounts == [PostFilterAccount(code: "Kano_Example", isBilibili: false)])
    }

    @Test func handleMatchesWithoutCase() throws {
        let (_, cards) = try Self.recent()

        #expect(PostRecentFilter.cards(cards, code: "kano_example").map(\.id) == ["1", "3"])
    }

    @Test func bilibiliChoiceShowsTheBilibiliPosts() throws {
        let (_, cards) = try Self.recent()

        #expect(PostRecentFilter.cards(cards, code: PostRecentFilter.bilibiliCode).map(\.id) == ["4"])
    }

    @Test func allKeepsTheDashboardsOrder() throws {
        let (_, cards) = try Self.recent()

        #expect(PostRecentFilter.cards(cards, code: nil).map(\.id) == ["1", "2", "3", "4", "5"])
    }

    /// Two posts by the main account, one by the sub account, one on
    /// Bilibili and one by an account outside the filter.
    private static func recent() throws -> (DashboardMeta, [PostCard]) {
        var fixture = DashboardFixture()
        fixture.xAccounts = ["Kano_Example", "_Sub"]
        fixture.bilibiliAccounts = ["316381099"]
        fixture.posts = [
            PostFixtures.json(id: "1", handle: "Kano_Example"),
            PostFixtures.json(id: "2", handle: "_Sub"),
            PostFixtures.json(id: "3", handle: "@kano_example"),
            PostFixtures.json(id: "4", source: "bilibili", handle: "316381099"),
            PostFixtures.json(id: "5", handle: "agency", promoted: true),
        ]
        let dashboard = try fixture.dashboard()
        return (dashboard.meta, dashboard.posts.map(PostCard.init(post:)))
    }
}
