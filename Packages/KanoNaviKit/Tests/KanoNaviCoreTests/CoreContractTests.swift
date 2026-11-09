import Foundation
import Testing
@testable import KanoNaviCore

struct FakeTransport: APITransport {
    var responses: [TransportResponse]
    var index: Int = 0
    func send(_ request: URLRequest) async throws -> TransportResponse {
        guard responses.indices.contains(index) else { throw URLError(.notConnectedToInternet) }
        return responses[index]
    }
}

struct CoreContractTests {
    private func fixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func decodesDashboardAndResolvesMedia() async throws {
        let data = try fixture()
        let transport = FakeTransport(responses: [TransportResponse(data: data, statusCode: 200, headers: ["etag":"W/\"one\""])])
        let cache = MemoryResponseCache()
        let client = try APIClient(baseURL: URL(string: "https://api.example.com")!, transport: transport, cache: cache)
        let dashboard = try await client.dashboard()
        #expect(dashboard.projection?.version == 1)
        #expect(dashboard.profile.avatarURL?.absoluteString == "https://api.example.com/media/avatar")
        #expect(dashboard.videos.first?.thumbnailURL?.absoluteString == "https://api.example.com/media/thumb")
    }

    @Test func unknownCodesSurviveDecoding() throws {
        let decoder = JSONDecoder.kanoNavi()
        let status = try decoder.decode(LiveStatus.self, from: Data("\"future\"".utf8))
        let platform = try decoder.decode(EventPlatform.self, from: Data("\"new-platform\"".utf8))
        #expect(status == .unknown("future"))
        #expect(platform == .unknown("new-platform"))
    }

    @Test func japanDateUsesTokyoAndMondayGrid() throws {
        let instant = try #require(KanoNaviDateCoding.date(from: "2026-11-09T14:59:59Z"))
        #expect(JapanDate.date(from: instant).rawValue == "2026-11-09")
        let next = try #require(KanoNaviDateCoding.date(from: "2026-11-09T15:00:00Z"))
        #expect(JapanDate.date(from: next).rawValue == "2026-11-10")
        let grid = try #require(JapanDate(rawValue: "2026-11-01")).monthGrid
        #expect(grid.count == 42)
        #expect(grid.first?.rawValue == "2026-10-26")
    }

    @Test(arguments: [ContentLanguage.en, .ja, .zhHans])
    func resolvesTranslations(_ language: ContentLanguage) {
        let translations = Translations(en: Translation(text: "English", origin: .manual), ja: Translation(text: "日本語", origin: .platform), zhCN: Translation(text: "中文", origin: .machine))
        let result = ContentLanguageResolver.resolve(original: "原文", sourceLanguage: "en", translations: translations, preference: language)
        #expect(result.isTranslation)
        #expect(result.original == "原文")
    }

    @Test func japaneseSourceStaysOriginal() {
        let result = ContentLanguageResolver.resolve(original: "日本語", sourceLanguage: "ja", translations: Translations(en: Translation(text: "Japanese", origin: .machine)), preference: .ja)
        #expect(result.text == "日本語")
        #expect(result.isTranslation == false)
    }

    @Test func cacheRoundTripAnd304() async throws {
        let data = try fixture()
        let cache = MemoryResponseCache()
        let first = try APIClient(baseURL: URL(string: "https://api.example.com")!, transport: FakeTransport(responses: [TransportResponse(data: data, statusCode: 200, headers: ["etag":"etag-1"])]), cache: cache)
        _ = try await first.dashboard()
        let second = try APIClient(baseURL: URL(string: "https://api.example.com")!, transport: FakeTransport(responses: [TransportResponse(data: Data(), statusCode: 304)]), cache: cache)
        let snapshot = try await second.dashboard()
        #expect(snapshot.meta.revision == 1)
    }
}

extension CoreContractTests {
    @Test func japaneseLabelResolvesFromPackageBundle() throws {
        let path = try #require(KanoNaviResources.bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: "ja.lproj"))
        let values = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
        #expect(values["event.state.live"] == "配信中")
    }
}

actor SequenceTransport: APITransport {
    private var responses: [Result<TransportResponse, Error>]
    init(_ responses: [Result<TransportResponse, Error>]) { self.responses = responses }
    func send(_ request: URLRequest) async throws -> TransportResponse {
        guard responses.isEmpty == false else { throw URLError(.notConnectedToInternet) }
        let response = responses.removeFirst()
        return try response.get()
    }
}

extension CoreContractTests {
    @Test func incompatibleDashboardIsRejected() async throws {
        var object = try JSONSerialization.jsonObject(with: fixture()) as? [String: Any]
        var projection = try #require(object?["projection"] as? [String: Any])
        projection["version"] = 2
        object?["projection"] = projection
        let body = try JSONSerialization.data(withJSONObject: try #require(object))
        let client = try APIClient(baseURL: try #require(URL(string: "https://api.example.com")), transport: SequenceTransport([.success(TransportResponse(data: body, statusCode: 200))]), cache: MemoryResponseCache())
        await #expect(throws: APIError.incompatible) { try await client.dashboard() }
    }

    @Test @MainActor func storeKeepsSnapshotAfterFailure() async throws {
        let data = try fixture()
        let transport = SequenceTransport([.success(TransportResponse(data: data, statusCode: 200)), .failure(URLError(.notConnectedToInternet))])
        let client = try APIClient(baseURL: try #require(URL(string: "https://api.example.com")), transport: transport, cache: MemoryResponseCache())
        let store = DashboardStore(client: client)
        await store.refresh()
        let previous = try #require(store.snapshot)
        await store.refresh()
        #expect(store.snapshot == previous)
        #expect(store.phase == .failed(.offline))
    }

    @Test func corruptFileCacheIsDiscarded() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let cache = FileResponseCache(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let key = "https://api.example.com/api/dashboard?days=7"
        let file = directory.appendingPathComponent(Data(key.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_") + ".json")
        try Data("not json".utf8).write(to: file)
        let loaded = await cache.load(key: key)
        #expect(loaded == nil)
        #expect(FileManager.default.fileExists(atPath: file.path) == false)
        try? FileManager.default.removeItem(at: directory)
    }
}

extension CoreContractTests {
    private func calendarEvent(id: String, day: String, startsAt: String) -> [String: Any] {
        [
            "id": id, "source": "x", "title": id, "startsOn": day, "startsAt": startsAt,
            "timezone": "Asia/Tokyo", "timePrecision": "exact", "eventType": "stream",
            "provenance": "automatic", "cancellationStatus": "none", "view": [
                "state": "upcoming", "typeCode": "stream", "activityCode": "live",
                "activityContext": "stream", "isWork": false,
                "calendarEntries": [["saleMark": NSNull(), "startsOn": day, "startsAt": startsAt, "timePrecision": "exact"]]
            ]
        ]
    }

    private func calendarPage(events: [[String: Any]], page: Int, hasNext: Bool) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "events": events, "scheduleImages": [], "adjacent": ["previous": NSNull(), "next": NSNull()],
            "dayCounts": ["2026-11-10": events.count], "total": 2, "page": page,
            "pageSize": 1, "totalPages": 2, "hasNext": hasNext, "revision": 1
        ])
    }

    @Test func calendarReaderMergesPagesInServerOrder() async throws {
        let first = try calendarPage(events: [calendarEvent(id: "first", day: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")], page: 1, hasNext: true)
        let second = try calendarPage(events: [calendarEvent(id: "second", day: "2026-11-11", startsAt: "2026-11-11T01:00:00Z")], page: 2, hasNext: false)
        let transport = SequenceTransport([.success(TransportResponse(data: first, statusCode: 200)), .success(TransportResponse(data: second, statusCode: 200))])
        let client = try APIClient(baseURL: try #require(URL(string: "https://api.example.com")), transport: transport, cache: MemoryResponseCache())
        let reader = CalendarReader(client: client)
        let from = try #require(JapanDate(rawValue: "2026-11-10"))
        let result = try await reader.read(from: from, to: from.addingDays(1))
        #expect(result.events.map(\.id) == ["first", "second"])
    }

    @Test func widgetRangeReportsNextTransition() async throws {
        let page = try calendarPage(events: [calendarEvent(id: "next", day: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")], page: 1, hasNext: false)
        let client = try APIClient(baseURL: try #require(URL(string: "https://api.example.com")), transport: SequenceTransport([.success(TransportResponse(data: page, statusCode: 200))]), cache: MemoryResponseCache())
        let reader = CalendarReader(client: client)
        let today = try #require(JapanDate(rawValue: "2026-11-10"))
        let now = try #require(KanoNaviDateCoding.date(from: "2026-11-09T00:00:00Z"))
        let result = try await reader.widgetRange(today: today, now: now)
        #expect(result.events.count == 1)
        #expect(result.nextTransitionAt != nil)
        #expect(result.calendarEntries.count == 1)
    }
}
