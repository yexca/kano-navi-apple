import Foundation
import Testing

@testable import KanoNaviCore

struct FileResponseCacheTests {
    private let key = "https://api.example.com/api/dashboard?days=7"

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private func dashboardFixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func savedResponseLoadsBack() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let fetchedAt = try #require(KanoNaviDateCoding.date(from: "2026-11-10T12:34:56.789Z"))
        let saved = CachedResponse(body: Data("{\"a\":1}".utf8), etag: "W/\"one\"", fetchedAt: fetchedAt)

        await FileResponseCache(directory: directory).save(saved, key: key)
        // A new instance reads the same files, as the next launch does.
        let loaded = await FileResponseCache(directory: directory).load(key: key)

        #expect(loaded == saved)
    }

    @Test func entryWithWholeSecondTimestampLoads() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = FileResponseCache(directory: directory)
        await cache.save(CachedResponse(body: Data(), etag: nil, fetchedAt: Date()), key: key)
        let file = try #require(
            FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil).first)
        let json = #"{"body":"","fetchedAt":"2026-11-10T12:34:56Z"}"#
        try Data(json.utf8).write(to: file)

        let loaded = await cache.load(key: key)

        #expect(loaded?.fetchedAt == KanoNaviDateCoding.date(from: "2026-11-10T12:34:56Z"))
        #expect(loaded?.etag == nil)
    }

    @Test func corruptEntryIsDiscarded() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = FileResponseCache(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let filename = Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
        let file = directory.appendingPathComponent(filename + ".json")
        try Data("not json".utf8).write(to: file)

        let loaded = await cache.load(key: key)

        #expect(loaded == nil)
        #expect(FileManager.default.fileExists(atPath: file.path) == false)
    }

    @Test func notModifiedIsServedFromAnEarlierFileEntry() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let baseURL = try #require(URL(string: "https://api.example.com"))
        let first = try APIClient(
            baseURL: baseURL,
            transport: FixtureTransport(
                response: TransportResponse(
                    data: try dashboardFixture(), statusCode: 200, headers: ["ETag": "W/\"one\""])),
            cache: FileResponseCache(directory: directory))
        let fresh = try await first.dashboard()
        let firstFetchedAt = try #require(await first.cachedFetchedAt(DashboardRequest()))

        let transport = SequenceTransport([
            .success(TransportResponse(data: Data(), statusCode: 304))
        ])
        let second = try APIClient(
            baseURL: baseURL, transport: transport, cache: FileResponseCache(directory: directory))
        let revalidated = try await second.dashboard()

        let request = try #require(await transport.requests.first)
        #expect(request.value(forHTTPHeaderField: "If-None-Match") == "W/\"one\"")
        #expect(revalidated == fresh)
        let secondFetchedAt = try #require(await second.cachedFetchedAt(DashboardRequest()))
        #expect(secondFetchedAt >= firstFetchedAt)
    }
}
