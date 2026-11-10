import Foundation
import KanoNaviCore
import Testing

struct UpcomingLoaderTests {
    private let baseURL = URL(string: "https://api.example.com")

    private func loader(_ transport: StubTransport, cache: any ResponseCache) throws -> UpcomingLoader {
        UpcomingLoader(
            client: try APIClient(baseURL: try #require(baseURL), transport: transport, cache: cache))
    }

    private func page() throws -> TransportResponse {
        TransportResponse(data: try CalendarFixture.page(WeekFixture.records), statusCode: 200)
    }

    @Test func freshReadIsNotStale() async throws {
        let loader = try loader(StubTransport([.success(try page())]), cache: MemoryResponseCache())
        let result = try #require(await loader.load(now: CalendarFixture.now))
        #expect(result.isStale == false)
        #expect(result.events.count == WeekFixture.records.count)
    }

    @Test func failedReadShowsTheCachedResultMarkedStale() async throws {
        let cache = MemoryResponseCache()
        let firstReadAt = Date.now
        _ = try await loader(StubTransport([.success(try page())]), cache: cache)
            .load(now: CalendarFixture.now)
        let secondReadAt = Date.now

        let offline = try loader(StubTransport([.failure(URLError(.notConnectedToInternet))]), cache: cache)
        let result = try #require(await offline.load(now: CalendarFixture.now))

        #expect(result.isStale)
        #expect(result.events.count == WeekFixture.records.count)
        let fetchedAt = try #require(result.fetchedAt)
        #expect(fetchedAt >= firstReadAt)
        #expect(fetchedAt <= secondReadAt)
    }

    @Test func failedReadWithoutCacheHasNoResult() async throws {
        let loader = try loader(StubTransport([.failure(URLError(.timedOut))]), cache: MemoryResponseCache())
        #expect(await loader.load(now: CalendarFixture.now) == nil)
    }

    @Test func staleScheduleKeepsItsReadTime() async throws {
        let cache = MemoryResponseCache()
        _ = try await loader(StubTransport([.success(try page())]), cache: cache)
            .load(now: CalendarFixture.now)
        let result = try #require(
            await loader(StubTransport([]), cache: cache).load(now: CalendarFixture.now))
        let schedule = WidgetSchedule(
            result: result, language: .en, interfaceLocale: Locale(identifier: "en_US"))
        #expect(schedule.isStale)
        #expect(schedule.fetchedAt == result.fetchedAt)
    }
}
