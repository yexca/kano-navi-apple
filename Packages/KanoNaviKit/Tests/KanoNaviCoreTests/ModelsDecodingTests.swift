import Foundation
import Testing

@testable import KanoNaviCore

struct ModelsDecodingTests {
    private func fixture(_ name: String) throws -> Data {
        let filename = name + ".json"
        let candidates = [
            Bundle.module.url(forResource: name, withExtension: "json"),
            Bundle.module.bundleURL.appendingPathComponent(filename),
            Bundle.module.bundleURL
                .appendingPathComponent("KanoNaviKit_KanoNaviCoreTests.bundle")
                .appendingPathComponent(filename),
            Bundle.module.bundleURL
                .appendingPathComponent("Contents/Resources/KanoNaviKit_KanoNaviCoreTests.bundle")
                .appendingPathComponent(filename),
        ].compactMap { $0 }
        let url = try #require(candidates.first { FileManager.default.fileExists(atPath: $0.path) })
        return try Data(contentsOf: url)
    }

    @Test func decodesEveryEndpointFixture() throws {
        let decoder = JSONDecoder.kanoNavi()
        _ = try decoder.decode(Dashboard.self, from: fixture("dashboard"))
        _ = try decoder.decode(CalendarPage.self, from: fixture("calendar-page-1"))
        _ = try decoder.decode(CalendarPage.self, from: fixture("calendar-page-2"))
        _ = try decoder.decode(PostArchivePage.self, from: fixture("posts-page"))
        _ = try decoder.decode(VideoArchivePage.self, from: fixture("videos-page"))
        _ = try decoder.decode(ArchiveMonthsResponse.self, from: fixture("post-months"))
        _ = try decoder.decode(ArchiveMonthsResponse.self, from: fixture("video-months"))
        _ = try decoder.decode(WorksUploadsResponse.self, from: fixture("works-uploads"))
        _ = try decoder.decode(HealthResponse.self, from: fixture("health"))
        _ = try decoder.decode(RevisionResponse.self, from: fixture("revision"))
    }

    @Test func unknownCodesRoundTrip() throws {
        let decoder = JSONDecoder.kanoNavi()
        let status = try decoder.decode(LiveStatus.self, from: Data("\"future\"".utf8))
        let platform = try decoder.decode(EventPlatform.self, from: Data("\"new-platform\"".utf8))
        let eventState = try decoder.decode(EventState.self, from: Data("\"new-state\"".utf8))
        #expect(status == .unknown("future"))
        #expect(platform == .unknown("new-platform"))
        #expect(eventState == .unknown("new-state"))
    }
}
