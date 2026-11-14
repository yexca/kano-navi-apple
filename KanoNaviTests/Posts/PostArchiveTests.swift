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

    @Test func pageEntriesCarryThePagesResolvedAvatars() async throws {
        let page: [String: Any] = [
            "items": [PostFixtures.json(id: "1", handle: "kano_example")],
            "adjacent": ["previous": NSNull(), "next": NSNull()], "total": 1, "page": 1, "hasNext": false,
            "revision": 1, "accountAvatars": ["x:kano_example": "/media/account-avatar/x/kano_example?v=2"],
        ]
        let body = try JSONSerialization.data(withJSONObject: page)
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: ClosureTransport { _ in TransportResponse(data: body, statusCode: 200) },
            cache: MemoryResponseCache())

        let loaded = try await PostArchiveSource.page(client: client)(
            ArchiveQuery(month: ArchiveFixtures.october, filter: nil, page: 1))
        let entry = try #require(loaded.items.first)

        #expect(entry.post.id == "1")
        #expect(
            entry.accountAvatars?["x:kano_example"]??.absoluteString
                == "https://api.example.com/media/account-avatar/x/kano_example?v=2")
    }

    @Test func recentPostsKeepTheDashboardsOrder() throws {
        var fixture = DashboardFixture()
        fixture.posts = ["3", "1", "2"].map { PostFixtures.json(id: $0) }

        let cards = try fixture.dashboard().posts.map {
            PostCard(post: $0, accountAvatars: nil, profileAvatarURL: nil)
        }

        #expect(cards.map(\.id) == ["3", "1", "2"])
    }
}
