import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostArchiveTests {
    @Test func accountFilterListsTheXAccountsThenBilibiliWithLowercaseCounts() throws {
        var fixture = DashboardFixture()
        fixture.xAccounts = ["Kano_Example", "_Sub"]
        fixture.bilibiliAccounts = ["316381099"]
        let meta = try fixture.dashboard().meta
        let counts = ["kano_example": 2, "_sub": 1, "316381099": 1, "agency": 1]

        let accounts = PostAccountFilter.accounts(meta: meta, counts: counts)
        let options = PostAccountFilter.options(accounts: accounts, counts: counts, allCount: 5)

        #expect(options.map(\.code) == [nil, "Kano_Example", "_Sub", "316381099"])
        #expect(options.map(\.count) == [5, 2, 1, 1])
        #expect(options[1].label == .verbatim("@Kano_Example"))
        #expect(options.map(\.logo) == [nil, .x, .x, .bilibili])
    }

    @Test func withoutASnapshotTheFilterOffersTheCountedAccounts() {
        let accounts = PostAccountFilter.accounts(meta: nil, counts: ["b": 1, "a": 2])

        #expect(accounts.map(\.code) == ["a", "b"])
    }

    @Test func accountCountsAreUnknownBeforeTheMonthLoads() {
        let options = PostAccountFilter.options(
            accounts: [PostFilterAccount(code: "a", isBilibili: false)], counts: [:], allCount: nil)

        #expect(options.allSatisfy { $0.count == nil })
    }

    @Test func monthPageRequestCoversTheMonthWithTheAccount() throws {
        let request = PostArchiveSource.request(
            for: ArchiveQuery(month: ArchiveFixtures.october, filter: "_sub", page: 2))

        try request.validate()
        #expect(request.from == JapanDate(year: 2026, month: 10, day: 1))
        #expect(request.to == JapanDate(year: 2026, month: 10, day: 31))
        #expect(request.page == 2)
        #expect(request.account == "_sub")
    }

    @Test func recentPostsKeepTheDashboardsOrder() throws {
        var fixture = DashboardFixture()
        fixture.posts = ["3", "1", "2"].map { PostFixtures.json(id: $0) }

        let cards = try fixture.dashboard().posts.map(PostCard.init)

        #expect(cards.map(\.id) == ["3", "1", "2"])
    }
}
