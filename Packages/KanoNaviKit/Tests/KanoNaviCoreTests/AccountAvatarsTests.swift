import Foundation
import Testing

@testable import KanoNaviCore

/// `accountAvatars` on the dashboard and the posts archive: an entry, a
/// hidden avatar's explicit `null` and a missing key stay distinct through
/// decoding, the cache and URL resolution.
struct AccountAvatarsTests {
    private let avatars: [String: Any] = [
        "x:kano_example": "/media/account-avatar/x/kano_example?v=2",
        "x:hidden_example": NSNull(),
        "x:remote_example": "https://cdn.example.com/media/account-avatar/x/remote_example?v=1",
    ]

    private func client(_ transport: any APITransport, cache: any ResponseCache = MemoryResponseCache())
        throws -> APIClient
    {
        try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")), transport: transport, cache: cache)
    }

    private func dashboardObject() throws -> [String: Any] {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try #require(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    }

    private func dashboardBody(avatars: [String: Any]?) throws -> Data {
        var object = try dashboardObject()
        object["accountAvatars"] = avatars
        return try JSONSerialization.data(withJSONObject: object)
    }

    @Test func dashboardWithoutTheFieldHasNoMap() throws {
        let dashboard = try JSONDecoder.kanoNavi().decode(Dashboard.self, from: dashboardBody(avatars: nil))

        #expect(dashboard.accountAvatars == nil)
    }

    @Test func entryHiddenNullAndMissingKeyStayDistinct() throws {
        let dashboard = try JSONDecoder.kanoNavi().decode(Dashboard.self, from: dashboardBody(avatars: avatars))
        let map = try #require(dashboard.accountAvatars)

        #expect(map["x:kano_example"] == .some(URL(string: "/media/account-avatar/x/kano_example?v=2")))
        #expect(map["x:hidden_example"] == .some(nil))
        #expect(map["x:missing_example"] == nil)
    }

    @Test func hiddenNullSurvivesReencoding() throws {
        let decoded = try JSONDecoder.kanoNavi().decode(Dashboard.self, from: dashboardBody(avatars: avatars))

        let data = try JSONEncoder.kanoNavi().encode(decoded)
        let again = try JSONDecoder.kanoNavi().decode(Dashboard.self, from: data)

        #expect(again == decoded)
        #expect(again.accountAvatars?["x:hidden_example"] == .some(nil))
    }

    @Test func dashboardAvatarsResolveAgainstTheBaseURL() async throws {
        let body = try dashboardBody(avatars: avatars)
        let api = try client(SequenceTransport([.success(TransportResponse(data: body, statusCode: 200))]))

        let map = try #require(try await api.dashboard().accountAvatars)

        #expect(
            map["x:kano_example"]??.absoluteString
                == "https://api.example.com/media/account-avatar/x/kano_example?v=2")
        #expect(
            map["x:remote_example"]??.absoluteString
                == "https://cdn.example.com/media/account-avatar/x/remote_example?v=1")
        #expect(map["x:hidden_example"] == .some(nil))
    }

    @Test func cachedDashboardKeepsTheHiddenNull() async throws {
        let cache = MemoryResponseCache()
        let body = try dashboardBody(avatars: avatars)
        _ = try await client(
            SequenceTransport([.success(TransportResponse(data: body, statusCode: 200))]), cache: cache
        ).dashboard()
        let offline = try client(SequenceTransport([]), cache: cache)

        let cached = try #require(await offline.cached(DashboardRequest()))

        #expect(cached.accountAvatars?["x:hidden_example"] == .some(nil))
        #expect(
            cached.accountAvatars?["x:kano_example"]??.absoluteString
                == "https://api.example.com/media/account-avatar/x/kano_example?v=2")
    }

    @Test func postsPageAvatarsResolveAgainstTheBaseURL() async throws {
        let page: [String: Any] = [
            "items": [], "adjacent": ["previous": NSNull(), "next": NSNull()], "total": 0, "page": 1,
            "hasNext": false, "revision": 1, "accountAvatars": avatars,
        ]
        let body = try JSONSerialization.data(withJSONObject: page)
        let api = try client(SequenceTransport([.success(TransportResponse(data: body, statusCode: 200))]))

        let map = try #require(try await api.posts(PostsRequest()).accountAvatars)

        #expect(
            map["x:kano_example"]??.absoluteString
                == "https://api.example.com/media/account-avatar/x/kano_example?v=2")
        #expect(map["x:hidden_example"] == .some(nil))
    }
}
