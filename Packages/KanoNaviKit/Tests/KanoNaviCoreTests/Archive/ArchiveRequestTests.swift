import Foundation
import Testing

@testable import KanoNaviCore

struct ArchiveRequestTests {
    @Test func requestPaths() {
        #expect(JourneyRequest().path == "/api/journey")
        #expect(WorksRequest().path == "/api/works")
        #expect(WorksUploadListRequest().path == "/api/works/upload-list")
        #expect(WorksUploadsRequest().path == "/api/works/uploads")
        #expect(LineBlogIndexRequest().path == "/api/lineblog")
        #expect(LineBlogPostRequest(id: "13162309").path == "/api/lineblog/posts/13162309")
        #expect(LineBlogPostRequest(id: 42).path == "/api/lineblog/posts/42")
        #expect(
            LineBlogCommentsRequest(articleID: "13162309").path == "/api/lineblog/posts/13162309/comments")
        #expect(JourneyRequest().queryItems.isEmpty)
    }

    @Test(arguments: ["", "abc", "12a", "0", "0123", "-1", "1/2", "１２３", " 12"])
    func malformedArticleIDsFailValidation(id: String) {
        #expect(throws: RequestValidationError.invalidArticleID) {
            try LineBlogPostRequest(id: id).validate()
        }
        #expect(throws: RequestValidationError.invalidArticleID) {
            try LineBlogCommentsRequest(articleID: id).validate()
        }
    }

    @Test func malformedArticleIDIsNeitherSentNorAnsweredFromTheCache() async throws {
        let transport = SequenceTransport([])
        let api = try APIClient(
            baseURL: ArchiveFixtures.baseURL, transport: transport, cache: MemoryResponseCache())
        await #expect(throws: RequestValidationError.invalidArticleID) {
            try await api.readResult(LineBlogPostRequest(id: "abc"))
        }
        #expect(await transport.requestCount() == 0)
    }

    @Test func unknownArticleIsA404() async throws {
        let api = try ArchiveFixtures.client([:])
        await #expect(throws: APIError.http(status: 404)) {
            try await api.lineBlogPost(id: "1")
        }
        await #expect(throws: APIError.http(status: 404)) {
            try await api.lineBlogComments(articleID: "1")
        }
    }

    @Test func archiveReadsRevalidateThroughTheirETag() async throws {
        let cache = MemoryResponseCache()
        let body = try ArchiveFixtures.data("journey")
        let first = SequenceTransport([
            .success(TransportResponse(data: body, statusCode: 200, headers: ["ETag": #"W/"j1""#]))
        ])
        let fresh = try await APIClient(baseURL: ArchiveFixtures.baseURL, transport: first, cache: cache)
            .journey()

        let second = SequenceTransport([.success(TransportResponse(data: Data(), statusCode: 304))])
        let revalidated = try await APIClient(
            baseURL: ArchiveFixtures.baseURL, transport: second, cache: cache
        )
        .journey()

        #expect(revalidated == fresh)
        let request = try #require(await second.requests.first)
        #expect(request.value(forHTTPHeaderField: "If-None-Match") == #"W/"j1""#)
    }

    @Test func worksUploadsMatchTheContract() throws {
        let json = #"""
            {"updatedAt":"2026-11-07","revision":4,"uploads":{"2010-03-28-ddd444":{"cover":{"url":"/media/abc?v=1",
            "width":null,"height":null},"videos":[{"source":"youtube","id":"yt1","title":"Song",
            "url":"https://video.example.com/watch?v=yt1","publishedAt":"2026-11-01T00:00:00Z","scheduledAt":null,
            "durationSeconds":200,"availability":"members","translations":null,"sourceLanguage":"ja"}]}},
            "recent":[{"id":"yt2","source":"youtube","title":"New","url":"https://video.example.com/watch?v=yt2",
            "publishedAt":null,"cover":null,"origin":"operator","translations":null,"sourceLanguage":null,
            "alternates":[{"source":"bilibili","url":"https://bili.example.com/video/BV1"}]},
            {"id":"BV3","source":"niconico","title":"Other","url":"https://bili.example.com/video/BV3",
            "publishedAt":"2026-11-02T00:00:00Z","cover":{"url":"/media/def?v=2","width":96,"height":64},
            "origin":"curated","translations":null,"sourceLanguage":null,"alternates":[]}],
            "recentTotal":60}
            """#
        let uploads = try ArchiveFixtures.decode(WorksUploadsResponse.self, from: json)
            .resolvingMedia(against: ArchiveFixtures.baseURL)
        let state = try #require(uploads.uploads["2010-03-28-ddd444"])
        #expect(state.cover?.url.absoluteString == "https://api.example.com/media/abc?v=1")
        #expect(state.cover?.width == nil)
        #expect(state.videos.first?.source == .youtube)
        #expect(state.videos.first?.availability == .members)
        #expect(uploads.recent.map(\.source) == [.youtube, .unknown("niconico")])
        #expect(uploads.recent.map(\.origin) == [.operator, .unknown("curated")])
        #expect(uploads.recent[0].publishedAt == nil)
        #expect(uploads.recent[0].alternates.first?.source == "bilibili")
        #expect(uploads.recent[1].cover?.url.absoluteString == "https://api.example.com/media/def?v=2")
        #expect(uploads.recentTotal == 60)
    }
}
