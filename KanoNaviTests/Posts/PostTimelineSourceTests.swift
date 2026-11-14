import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostTimelineSourceTests {
    @Test func newestRequestIsTheWholeTimelineAtTheAPIsLargestPage() throws {
        let request = PostTimelineSource.request(for: PostTimelineFixtures.query(page: 3))

        try request.validate()
        #expect(request.from == nil)
        #expect(request.to == nil)
        #expect(request.until == nil)
        #expect(request.page == 3)
        #expect(request.pageSize == 50)
        #expect(request.queryItems.map(\.name) == ["page", "pageSize"])
    }

    @Test func startAndAccountNarrowTheRequest() throws {
        let request = PostTimelineSource.request(
            for: PostTimelineFixtures.query(ArchiveFixtures.october, account: "_sub", page: 2))

        try request.validate()
        #expect(request.until == JapanDate(year: 2026, month: 10, day: 31))
        #expect(request.account == "_sub")
        #expect(request.queryItems.map(\.name) == ["until", "page", "pageSize", "account"])
    }

    @Test func pageEntriesCarryThePagesResolvedAvatarsAndRevision() async throws {
        let page: [String: Any] = [
            "items": [PostFixtures.json(id: "1", handle: "kano_example")],
            "adjacent": ["previous": NSNull(), "next": NSNull()], "total": 1, "page": 1, "hasNext": false,
            "revision": 7, "accountCounts": ["kano_example": 1],
            "accountAvatars": ["x:kano_example": "/media/account-avatar/x/kano_example?v=2"],
        ]
        let body = try JSONSerialization.data(withJSONObject: page)
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: ClosureTransport { _ in TransportResponse(data: body, statusCode: 200) },
            cache: MemoryResponseCache())

        let loaded = try await PostTimelineSource.page(client: client)(PostTimelineFixtures.query())
        let entry = try #require(loaded.items.first)

        #expect(entry.post.id == "1")
        #expect(loaded.revision == 7)
        #expect(loaded.counts == ["kano_example": 1])
        #expect(
            entry.accountAvatars?["x:kano_example"]??.absoluteString
                == "https://api.example.com/media/account-avatar/x/kano_example?v=2")
    }
}
