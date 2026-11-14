import Foundation
import Testing

@testable import KanoNaviCore

struct ClientCacheTests {
    private func dashboardFixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func client(
        transport: any APITransport,
        cache: any ResponseCache = MemoryResponseCache()
    ) throws -> APIClient {
        try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: cache
        )
    }

    @Test func dashboardResolvesMediaURLs() async throws {
        let data = try dashboardFixture()
        let transport = FixtureTransport(
            response: TransportResponse(
                data: data,
                statusCode: 200,
                headers: ["etag": "W/\"one\""]
            )
        )
        let dashboard = try await client(transport: transport).dashboard()
        #expect(dashboard.projection?.version == 1)
        #expect(dashboard.profile.avatarURL?.absoluteString == "https://api.example.com/media/avatar")
        #expect(
            dashboard.videos.first?.thumbnailURL?.absoluteString == "https://api.example.com/media/thumb")
    }

    @Test func summaryVideosResolveMediaURLs() throws {
        var dashboard = try JSONDecoder.kanoNavi().decode(Dashboard.self, from: dashboardFixture())
        dashboard.summary.latestVideo = dashboard.videos.first
        dashboard.summary.nextStream = dashboard.videos.first
        let baseURL = try #require(URL(string: "https://api.example.com"))
        let resolved = dashboard.resolvingMedia(against: baseURL)
        #expect(
            resolved.summary.latestVideo?.thumbnailURL?.absoluteString
                == "https://api.example.com/media/thumb")
        #expect(
            resolved.summary.nextStream?.thumbnailURL?.absoluteString == "https://api.example.com/media/thumb"
        )
    }

    @Test func etag304KeepsCachedBody() async throws {
        let cache = MemoryResponseCache()
        let first = try client(
            transport: FixtureTransport(
                response: TransportResponse(
                    data: dashboardFixture(),
                    statusCode: 200,
                    headers: ["etag": "etag-1"]
                )
            ),
            cache: cache
        )
        _ = try await first.dashboard()
        let second = try client(
            transport: FixtureTransport(response: TransportResponse(data: Data(), statusCode: 304)),
            cache: cache
        )
        let snapshot = try await second.dashboard()
        #expect(snapshot.meta.revision == 1)
    }

    @Test(arguments: [false, true])
    func incompatibleDashboardKeepsNoValue(_ removeProjection: Bool) async throws {
        var object = try #require(
            JSONSerialization.jsonObject(with: dashboardFixture()) as? [String: Any]
        )
        if removeProjection {
            object.removeValue(forKey: "projection")
        } else {
            var projection = try #require(object["projection"] as? [String: Any])
            projection["version"] = 2
            object["projection"] = projection
        }
        let body = try JSONSerialization.data(withJSONObject: object)
        let api = try client(
            transport: FixtureTransport(response: TransportResponse(data: body, statusCode: 200))
        )
        await #expect(throws: APIError.incompatible) {
            try await api.dashboard()
        }
    }
}
