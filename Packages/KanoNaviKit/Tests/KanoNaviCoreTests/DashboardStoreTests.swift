import Foundation
import Testing

@testable import KanoNaviCore

@MainActor
struct DashboardStoreTests {
    private func fixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func dashboardData(revision: Int? = nil, transition: String? = nil) throws -> Data {
        var object = try #require(JSONSerialization.jsonObject(with: fixture()) as? [String: Any])
        if let revision {
            var meta = try #require(object["meta"] as? [String: Any])
            meta["revision"] = revision
            object["meta"] = meta
        }
        if let transition {
            var projection = try #require(object["projection"] as? [String: Any])
            projection["nextTransitionAt"] = transition
            object["projection"] = projection
        }
        return try JSONSerialization.data(withJSONObject: object)
    }

    private func api(transport: any APITransport) throws -> APIClient {
        try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
    }

    private func waitForSnapshot(_ store: DashboardStore) async throws {
        for _ in 0..<1000 {
            if store.snapshot != nil, store.phase == .idle {
                for _ in 0..<20 {
                    await Task.yield()
                }
                try await Task.sleep(for: .milliseconds(1))
                return
            }
            await Task.yield()
        }
        _ = try #require(store.snapshot)
    }

    private func waitForRevision(_ store: DashboardStore, _ revision: Int) async throws {
        for _ in 0..<1000 {
            if store.snapshot?.meta.revision == revision, store.phase == .idle {
                return
            }
            await Task.yield()
        }
        #expect(store.snapshot?.meta.revision == revision)
    }

    private func waitForRequests(
        _ transport: SequenceTransport,
        count: Int
    ) async throws {
        for _ in 0..<1000 {
            if await transport.requestCount() >= count {
                return
            }
            await Task.yield()
        }
        Issue.record("Timed out waiting for (count) requests")
    }

    private func waitForPhase(_ store: DashboardStore, _ expected: DashboardPhase) async {
        for _ in 0..<1000 {
            if store.phase == expected {
                return
            }
            await Task.yield()
        }
        #expect(store.phase == expected)
    }

    @Test func failureKeepsLastGoodSnapshot() async throws {
        let data = try fixture()
        let transport = SequenceTransport([
            .success(TransportResponse(data: data, statusCode: 200)),
            .failure(URLError(.notConnectedToInternet)),
        ])
        let store = DashboardStore(client: try api(transport: transport))
        await store.refresh()
        let previous = try #require(store.snapshot)
        await store.refresh()
        #expect(store.snapshot == previous)
        #expect(store.phase == .failed(.offline))
    }

    @Test(arguments: [false, true])
    func incompatibleRefreshKeepsLastGoodSnapshot(_ removeProjection: Bool) async throws {
        let valid = try fixture()
        var object = try #require(JSONSerialization.jsonObject(with: valid) as? [String: Any])
        if removeProjection {
            object.removeValue(forKey: "projection")
        } else {
            var projection = try #require(object["projection"] as? [String: Any])
            projection["version"] = 2
            object["projection"] = projection
        }
        let incompatible = try JSONSerialization.data(withJSONObject: object)
        let transport = SequenceTransport([
            .success(TransportResponse(data: valid, statusCode: 200)),
            .success(TransportResponse(data: incompatible, statusCode: 200)),
        ])
        let store = DashboardStore(client: try api(transport: transport))
        await store.refresh()
        let previous = try #require(store.snapshot)
        await store.refresh()
        #expect(store.snapshot == previous)
        #expect(store.phase == .failed(.incompatible))
        #expect(store.isIncompatible)
    }

    @Test func changedRevisionTriggersReload() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z")))
        let transport = SequenceTransport([
            .success(TransportResponse(data: try fixture(), statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":2}".utf8), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
        ])
        let store = DashboardStore(client: try api(transport: transport), clock: clock)
        store.start()
        try await waitForRequests(transport, count: 1)
        try await waitForSnapshot(store)
        clock.advance(by: 30)
        try await waitForRequests(transport, count: 3)
        try await waitForRevision(store, 2)
        #expect(store.snapshot?.meta.revision == 2)
        store.stop()
    }

    @Test func unchangedRevisionDoesNotReloadDashboard() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z")))
        let data = try fixture()
        let transport = SequenceTransport([
            .success(TransportResponse(data: data, statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":1}".utf8), statusCode: 200)),
        ])
        let store = DashboardStore(client: try api(transport: transport), clock: clock)
        store.start()
        try await waitForRequests(transport, count: 1)
        try await waitForSnapshot(store)
        clock.advance(by: 30)
        try await waitForRequests(transport, count: 2)
        #expect(await transport.requestCount() == 2)
        store.stop()
    }

    @Test func transitionAndRevalidationReload() async throws {
        let start = try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z"))
        let clock = ManualRefreshClock(now: start)
        let data = try dashboardData(transition: "2026-11-10T00:00:10Z")
        let sequence = SequenceTransport([
            .success(TransportResponse(data: data, statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":1}".utf8), statusCode: 200)),
            .success(TransportResponse(data: data, statusCode: 200)),
        ])
        let store = DashboardStore(client: try api(transport: sequence), clock: clock)
        store.start()
        try await waitForRequests(sequence, count: 1)
        try await waitForSnapshot(store)
        clock.advance(by: 10)
        try await waitForRequests(sequence, count: 2)
        store.stop()

        let revalidationClock = ManualRefreshClock(now: start)
        let revalidationTransport = SequenceTransport([
            .success(TransportResponse(data: data, statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":1}".utf8), statusCode: 200)),
            .success(TransportResponse(data: data, statusCode: 200)),
        ])
        let revalidationStore = DashboardStore(
            client: try api(transport: revalidationTransport),
            clock: revalidationClock
        )
        revalidationStore.start()
        try await waitForRequests(revalidationTransport, count: 1)
        try await waitForSnapshot(revalidationStore)
        revalidationClock.advance(by: 60)
        try await waitForRequests(revalidationTransport, count: 3)
        revalidationStore.stop()
    }

    @Test func stopDoesNotExposeCancellationFailure() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z")))
        let data = try fixture()
        let transport = FixtureTransport(response: TransportResponse(data: data, statusCode: 200))
        let store = DashboardStore(client: try api(transport: transport), clock: clock)
        store.start()
        try await waitForSnapshot(store)
        store.stop()
        #expect(store.phase == .idle)
        clock.advance(by: 120)
        await Task.yield()
        #expect(store.phase == .idle)
    }

    @Test func failedPollKeepsSnapshotAndClearsOnSuccess() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z")))
        let data = try fixture()
        let transport = SequenceTransport([
            .success(TransportResponse(data: data, statusCode: 200)),
            .failure(URLError(.notConnectedToInternet)),
            .success(TransportResponse(data: Data("{\"revision\":1}".utf8), statusCode: 200)),
            .success(TransportResponse(data: data, statusCode: 200)),
        ])
        let store = DashboardStore(client: try api(transport: transport), clock: clock)
        store.start()
        try await waitForRequests(transport, count: 1)
        try await waitForSnapshot(store)
        let snapshot = try #require(store.snapshot)
        clock.advance(by: 30)
        try await waitForRequests(transport, count: 2)
        await waitForPhase(store, .failed(.offline))
        #expect(store.snapshot == snapshot)
        #expect(store.phase == .failed(.offline))
        clock.advance(by: 30)
        try await waitForRequests(transport, count: 4)
        await waitForPhase(store, .idle)
        #expect(store.phase == .idle)
        #expect(store.snapshot == snapshot)
        store.stop()
    }
}
