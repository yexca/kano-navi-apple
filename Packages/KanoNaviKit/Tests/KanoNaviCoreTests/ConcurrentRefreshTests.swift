import Foundation
import Testing

@testable import KanoNaviCore

@MainActor
struct ConcurrentRefreshTests {
    @Test func concurrentRefreshAwaitsInFlightRequest() async throws {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let transport = GateTransport(response: TransportResponse(data: data, statusCode: 200))
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
        let store = DashboardStore(client: client)
        let first = Task { await store.refresh() }
        for _ in 0..<1000 where await transport.started == false {
            await Task.yield()
        }
        let second = Task { await store.refresh() }
        for _ in 0..<20 {
            await Task.yield()
        }
        #expect(store.snapshot == nil)
        await transport.release()
        await first.value
        await second.value
        #expect(store.snapshot != nil)
    }
}
