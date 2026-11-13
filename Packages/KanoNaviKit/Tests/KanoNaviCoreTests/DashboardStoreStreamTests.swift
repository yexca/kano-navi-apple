import Foundation
import Testing

@testable import KanoNaviCore

@MainActor
struct DashboardStoreStreamTests {
    private func fixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func dashboardData(revision: Int) throws -> Data {
        var object = try #require(JSONSerialization.jsonObject(with: fixture()) as? [String: Any])
        var meta = try #require(object["meta"] as? [String: Any])
        meta["revision"] = revision
        object["meta"] = meta
        return try JSONSerialization.data(withJSONObject: object)
    }

    private func api(transport: any APITransport) throws -> APIClient {
        try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
    }

    private func pause() async {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }

    private func waitForSnapshot(_ store: DashboardStore) async throws {
        for _ in 0..<1000 {
            if store.snapshot != nil, store.phase == .idle {
                return
            }
            await pause()
        }
        _ = try #require(store.snapshot)
    }

    private func waitForRevision(_ store: DashboardStore, _ revision: Int) async {
        for _ in 0..<1000 {
            if store.snapshot?.meta.revision == revision, store.phase == .idle {
                return
            }
            await pause()
        }
        #expect(store.snapshot?.meta.revision == revision)
    }

    private func waitForActiveStream(_ stream: ControlledRevisionStream) async {
        for _ in 0..<1000 {
            if stream.activeStreamCount > 0 {
                return
            }
            await pause()
        }
        #expect(stream.activeStreamCount > 0)
    }

    private func waitForConnectCount(_ stream: ControlledRevisionStream, atLeast expected: Int) async {
        for _ in 0..<1000 {
            if stream.connectCount >= expected {
                return
            }
            await pause()
        }
        #expect(stream.connectCount >= expected)
    }

    private func waitForRequests(_ transport: SequenceTransport, count: Int) async {
        for _ in 0..<1000 {
            if await transport.requestCount() >= count {
                return
            }
            await pause()
        }
        #expect(await transport.requestCount() >= count)
    }

    @Test func pushedRevisionReloadsAfterJitterAndSuppressesRevisionPolling() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z"))
        )
        let transport = SequenceTransport([
            .success(TransportResponse(data: try dashboardData(revision: 1), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
        ])
        let stream = ControlledRevisionStream(steps: [.open])
        let store = DashboardStore(
            client: try api(transport: transport),
            clock: clock,
            stream: stream,
            pushJitter: { 2.0 }
        )

        store.start()
        try await waitForSnapshot(store)
        await waitForActiveStream(stream)

        // Initial matching revision on connect must not trigger a second fetch.
        stream.send(.revision(1))
        for _ in 0..<20 { await pause() }
        clock.advance(by: 30)
        for _ in 0..<20 { await pause() }
        #expect(await transport.requestCount() == 1)

        // Pushed revision 2 waits for the 2-second jitter, then reloads the snapshot.
        stream.send(.revision(2))
        for _ in 0..<20 { await pause() }
        #expect(await transport.requestCount() == 1)

        clock.advance(by: 2)
        await waitForRequests(transport, count: 2)
        await waitForRevision(store, 2)
        store.stop()
    }

    @Test func threeConsecutiveStreamFailuresFallBackToPollingThenRecover() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z"))
        )
        let transport = SequenceTransport([
            .success(TransportResponse(data: try dashboardData(revision: 1), statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":2}".utf8), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 3), statusCode: 200)),
        ])
        let stream = ControlledRevisionStream(steps: [
            .fail(RevisionStreamError.disconnected),
            .fail(RevisionStreamError.disconnected),
            .fail(RevisionStreamError.disconnected),
            .open,
        ])
        let store = DashboardStore(
            client: try api(transport: transport),
            clock: clock,
            stream: stream,
            pushJitter: { 0 }
        )

        store.start()
        try await waitForSnapshot(store)
        await waitForConnectCount(stream, atLeast: 1)

        // Advance through the two 5s retry delays so the 3rd failure enters fallback.
        clock.advance(by: 5)
        await waitForConnectCount(stream, atLeast: 2)
        clock.advance(by: 5)
        await waitForConnectCount(stream, atLeast: 3)
        for _ in 0..<20 { await pause() }

        // Thirty seconds after entering fallback, revision polling reloads revision 2.
        clock.advance(by: 30)
        await waitForRevision(store, 2)

        // Advance past the remaining 300s fallback cooldown so the stream reconnects.
        for _ in 0..<5 {
            clock.advance(by: 60)
            for _ in 0..<10 { await pause() }
        }
        await waitForConnectCount(stream, atLeast: 4)
        await waitForActiveStream(stream)

        stream.send(.revision(3))
        await waitForRevision(store, 3)
        store.stop()
    }

    @Test func unavailableStreamImmediatelyEntersPollingFallbackAndStopCancelsStream() async throws {
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z"))
        )
        let transport = SequenceTransport([
            .success(TransportResponse(data: try dashboardData(revision: 1), statusCode: 200)),
            .success(TransportResponse(data: Data("{\"revision\":2}".utf8), statusCode: 200)),
            .success(TransportResponse(data: try dashboardData(revision: 2), statusCode: 200)),
        ])
        let stream = ControlledRevisionStream(steps: [
            .fail(RevisionStreamError.unavailable(retryAfter: 600)),
            .open,
        ])
        let store = DashboardStore(
            client: try api(transport: transport),
            clock: clock,
            stream: stream,
            pushJitter: { 0 }
        )

        store.start()
        try await waitForSnapshot(store)
        await waitForConnectCount(stream, atLeast: 1)
        for _ in 0..<20 { await pause() }

        #expect(stream.connectCount == 1)
        clock.advance(by: 30)
        await waitForRevision(store, 2)

        store.stop()
        #expect(store.phase == .idle)
    }
}
