import Foundation
import Testing

@testable import KanoNaviCore

struct ReadResultTests {
    private let monthsBody = Data(
        #"{"months":[{"month":"2026-11","total":3,"categoryCounts":{"game":1,"other":2}}],"revision":4}"#.utf8
    )

    private func client(_ transport: any APITransport, cache: any ResponseCache) throws -> APIClient {
        try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")), transport: transport, cache: cache)
    }

    @Test func freshReadIsNotFromCache() async throws {
        let transport = SequenceTransport([.success(TransportResponse(data: monthsBody, statusCode: 200))])
        let api = try client(transport, cache: MemoryResponseCache())

        let result = try await api.readResult(VideosMonthsRequest())

        #expect(result.isFromCache == false)
        #expect(result.value.months.map(\.month) == ["2026-11"])
        #expect(result.value.months.first?.counts == ["game": 1, "other": 2])
    }

    @Test func cachedResultImmediatelyReadsTheCacheWithoutTheService() async throws {
        let cache = MemoryResponseCache()
        let first = try client(
            SequenceTransport([.success(TransportResponse(data: monthsBody, statusCode: 200))]), cache: cache)
        let fresh = try await first.readResult(VideosMonthsRequest())
        let offline = try client(SequenceTransport([]), cache: cache)

        let result = try #require(offline.cachedResultImmediately(VideosMonthsRequest()))

        #expect(result.isFromCache)
        #expect(result.value == fresh.value)
        #expect(offline.cachedResultImmediately(PostsMonthsRequest()) == nil)
    }

    @Test func failedReadReturnsTheCachedResponseWithItsFetchTime() async throws {
        let cache = MemoryResponseCache()
        let first = try client(
            SequenceTransport([.success(TransportResponse(data: monthsBody, statusCode: 200))]), cache: cache)
        let fresh = try await first.readResult(VideosMonthsRequest())
        let offline = try client(
            SequenceTransport([.failure(URLError(.notConnectedToInternet))]), cache: cache)

        let result = try await offline.readResult(VideosMonthsRequest())

        #expect(result.isFromCache)
        #expect(result.fetchedAt <= fresh.fetchedAt)
        #expect(result.value == fresh.value)
    }

    @Test func failedReadWithNothingCachedThrowsTheServiceError() async throws {
        let api = try client(
            SequenceTransport([.success(TransportResponse(data: Data(), statusCode: 503))]),
            cache: MemoryResponseCache())

        await #expect(throws: APIError.http(status: 503)) {
            try await api.readResult(PostsMonthsRequest())
        }
    }

    @Test func invalidRequestIsNotAnsweredFromTheCache() async throws {
        let api = try client(SequenceTransport([]), cache: MemoryResponseCache())

        await #expect(throws: RequestValidationError.invalidCategory) {
            try await api.readResult(VideosRequest(category: "video"))
        }
    }

    @Test func quotedPostMediaResolvesAgainstTheBaseURL() async throws {
        let body = Data(
            #"""
            {"items":[{"id":"1","source":"x","accountHandle":"kano","accountUrl":null,
            "publishedAt":"2026-11-10T01:00:00Z","text":"t","url":"https://x.example.com/1","media":[],
            "mediaUrl":null,"mediaStatus":"none","quote":{"id":"2","authorHandle":"q","authorName":null,
            "text":"q","publishedAt":null,"url":"https://x.example.com/2","unavailable":false,
            "media":[{"id":"m","url":"/media/quote?v=1","status":"ready"}]}}],
            "adjacent":{"previous":null,"next":null},"total":1,"page":1,"pageSize":30,"totalPages":1,
            "hasNext":false,"revision":1,"accountCounts":{"kano":1}}
            """#.utf8)
        let api = try client(
            SequenceTransport([.success(TransportResponse(data: body, statusCode: 200))]),
            cache: MemoryResponseCache())

        let page = try await api.posts(PostsRequest())

        #expect(
            page.items.first?.quote?.media.first?.url?.absoluteString
                == "https://api.example.com/media/quote?v=1")
    }
}
