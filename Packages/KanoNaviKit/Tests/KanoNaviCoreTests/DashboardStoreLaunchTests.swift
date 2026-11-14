import Foundation
import Observation
import Synchronization
import Testing

@testable import KanoNaviCore

/// What a launch and a return to the foreground show: the saved copy from
/// the first frame, and nothing published for a refresh that changes
/// nothing.
@MainActor
struct DashboardStoreLaunchTests {
    private let cachedAt = KanoNaviDateCoding.date(from: "2026-11-09T12:00:00Z")

    private func fixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func dashboard(revision: Int) throws -> Data {
        var object = try #require(JSONSerialization.jsonObject(with: fixture()) as? [String: Any])
        var meta = try #require(object["meta"] as? [String: Any])
        meta["revision"] = revision
        object["meta"] = meta
        return try JSONSerialization.data(withJSONObject: object)
    }

    private func ok(_ data: Data) -> Result<TransportResponse, any Error> {
        .success(TransportResponse(data: data, statusCode: 200))
    }

    /// A cache holding the dashboard as an earlier launch saved it.
    private func cacheWithDashboard() async throws -> MemoryResponseCache {
        let cache = MemoryResponseCache()
        await cache.save(
            CachedResponse(body: try fixture(), etag: "W/\"one\"", fetchedAt: try #require(cachedAt)),
            key: "https://api.example.com/api/dashboard?days=7")
        return cache
    }

    private func store(
        _ transport: SequenceTransport, cache: any ResponseCache = MemoryResponseCache()
    ) throws -> DashboardStore {
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")), transport: transport, cache: cache)
        let clock = ManualRefreshClock(
            now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z")))
        return DashboardStore(client: client, clock: clock)
    }

    /// Whether the store tells observers of `read` about a change while
    /// `action` runs.
    private func publishes(
        _ read: @escaping @MainActor () -> Void, during action: () async -> Void
    ) async -> Bool {
        let changed = ChangeFlag()
        withObservationTracking(read) {
            changed.set()
        }
        await action()
        return changed.isSet
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<1000 where condition() == false {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    @Test func cachedSnapshotIsThereWhenTheStoreIsCreated() async throws {
        let transport = SequenceTransport([])
        let store = try store(transport, cache: try await cacheWithDashboard())

        #expect(store.snapshot != nil)
        #expect(store.source == .cache)
        #expect(store.fetchedAt == cachedAt)
        #expect(store.phase == .idle)
        #expect(await transport.requestCount() == 0)
    }

    @Test func refreshWithTheSameDashboardPublishesNothingOnScreen() async throws {
        let data = try fixture()
        let store = try store(SequenceTransport([ok(data), ok(data)]))
        await store.refresh()
        let first = try #require(store.snapshot)

        let published = await publishes {
            _ = store.snapshot
            _ = store.source
            _ = store.isIncompatible
        } during: {
            await store.refresh()
        }

        #expect(published == false)
        #expect(store.snapshot == first)
        #expect(store.phase == .idle)
    }

    @Test func refreshWithAChangedDashboardPublishesIt() async throws {
        let store = try store(
            SequenceTransport([ok(try dashboard(revision: 1)), ok(try dashboard(revision: 2))]))
        await store.refresh()

        let published = await publishes {
            _ = store.snapshot
        } during: {
            await store.refresh()
        }

        #expect(published)
        #expect(store.snapshot?.meta.revision == 2)
    }

    @Test func foregroundReturnKeepsTheSnapshotFromTheService() async throws {
        let transport = SequenceTransport([ok(try dashboard(revision: 2)), ok(try dashboard(revision: 2))])
        let store = try store(transport, cache: try await cacheWithDashboard())
        store.start()
        await waitUntil { store.source == .network && store.phase == .idle }
        try #require(store.source == .network)
        store.stop()

        store.start()

        // The cache is not read again over the newer snapshot.
        #expect(store.source == .network)
        #expect(store.snapshot?.meta.revision == 2)
        #expect(store.phase == .refreshing)
        store.stop()
    }

    @Test func foregroundRefreshKeepsAFailureOnScreenUntilItEnds() async throws {
        let data = try fixture()
        let store = try store(
            SequenceTransport([ok(data), .failure(URLError(.notConnectedToInternet))]))
        await store.refresh()
        await store.refresh()
        try #require(store.phase == .failed(.offline))

        store.start()

        #expect(store.phase == .failed(.offline))
        store.stop()
    }

    @Test func stopEndsTheRefreshItCancels() async throws {
        let gate = GateTransport(response: TransportResponse(data: try fixture(), statusCode: 200))
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")), transport: gate,
            cache: try await cacheWithDashboard())
        let store = DashboardStore(
            client: client,
            clock: ManualRefreshClock(
                now: try #require(KanoNaviDateCoding.date(from: "2026-11-10T00:00:00Z"))))
        store.start()
        for _ in 0..<1000 where await gate.started == false {
            await Task.yield()
        }
        try #require(store.phase == .refreshing)

        store.stop()
        await gate.release()
        await waitUntil { store.phase != .refreshing }

        #expect(store.phase == .idle)
        #expect(store.source == .cache)
    }
}

/// Set once from an observation's change handler, on any thread.
private final class ChangeFlag: Sendable {
    private let value = Mutex(false)
    func set() { value.withLock { $0 = true } }
    var isSet: Bool { value.withLock { $0 } }
}
