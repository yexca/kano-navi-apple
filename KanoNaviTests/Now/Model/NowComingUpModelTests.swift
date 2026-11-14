import Foundation
import KanoNaviCore
import Observation
import Synchronization
import Testing

@testable import KanoNavi

@MainActor
struct NowComingUpModelTests {
    private let today = JapanDate(year: 2026, month: 11, day: 10)
    private let fetchedAt = Date(timeIntervalSince1970: 1_794_000_000)

    private func result(_ ids: [String], isFromCache: Bool = false) throws -> CalendarReadResult {
        var fixture = DashboardFixture()
        fixture.events = ids.map {
            DashboardFixture.event(id: $0, startsOn: "2026-11-11", startsAt: "2026-11-11T12:00:00Z")
        }
        let page = CalendarPage(
            events: try fixture.dashboard().events, total: ids.count, page: 1, hasNext: false, revision: 1)
        return CalendarReadResult(page: page, isFromCache: isFromCache, fetchedAt: fetchedAt)
    }

    private func model(
        _ stub: StubCalendarLoader, cached: CalendarReadResult? = nil
    ) -> NowComingUpModel {
        NowComingUpModel(
            loader: { day in try await stub.load(day) }, cacheReader: { _ in cached },
            today: { [today] in today })
    }

    @Test func readsTheRangeFromTodayInJapan() async throws {
        let stub = StubCalendarLoader([.success(try result(["next"]))])
        let model = model(stub)

        await model.reload()

        #expect(await stub.requests == [today])
        #expect(model.events?.map(\.id) == ["next"])
        #expect(model.notice == nil)
    }

    @Test func cachedRangeIsShownWhileTheFirstReadRuns() async throws {
        let gate = LoadGate()
        let fresh = try result(["fresh"])
        let cached = try result(["cached"], isFromCache: true)
        let model = NowComingUpModel(
            loader: { _ in
                await gate.enter()
                return fresh
            },
            cacheReader: { _ in cached },
            today: { [today] in today })

        let load = Task { await model.reload() }
        while await gate.entries == 0 { await Task.yield() }

        #expect(model.events?.map(\.id) == ["cached"])
        #expect(model.notice == nil)

        await gate.open()
        await load.value

        #expect(model.events?.map(\.id) == ["fresh"])
    }

    @Test func rangeReadBeforeTheModelIsCreatedIsThereAtOnce() throws {
        let model = NowComingUpModel(
            loader: { _ in throw APIError.offline }, cached: try result(["cached"], isFromCache: true),
            today: { [today] in today })

        #expect(model.events?.map(\.id) == ["cached"])
        #expect(model.notice == nil)
    }

    @Test func reloadWithTheSameEventsPublishesNothing() async throws {
        let model = model(StubCalendarLoader([.success(try result(["next"]))]))
        await model.reload()
        let tracked = ObservationFlag()
        withObservationTracking {
            _ = model.result
            _ = model.failure
            _ = model.hasLoaded
        } onChange: {
            tracked.set()
        }

        await model.reload()

        #expect(tracked.isSet == false)
        #expect(model.events?.map(\.id) == ["next"])
    }

    @Test func freshReadReplacesTheCachedRangeEvenWithTheSameEvents() throws {
        let cached = try result(["next"], isFromCache: true)
        let fresh = try result(["next"])

        #expect(NowComingUpModel.changes(cached, to: fresh))
        #expect(NowComingUpModel.changes(fresh, to: fresh) == false)
        #expect(NowComingUpModel.changes(fresh, to: try result(["other"])))
    }

    @Test func cachedFallbackIsMarkedWithItsFetchTime() async throws {
        let stub = StubCalendarLoader([.success(try result(["cached"], isFromCache: true))])
        let model = model(stub)

        await model.reload()

        #expect(model.events?.map(\.id) == ["cached"])
        #expect(model.notice == .saved(fetchedAt: fetchedAt))
    }

    @Test func failedFirstReadWithNothingCachedSaysSo() async {
        let model = model(StubCalendarLoader([.failure(.offline)]))

        await model.reload()

        #expect(model.events == nil)
        #expect(model.notice == .loadFailed)
    }

    @Test func failedReloadKeepsTheLastGoodRangeUntilASuccess() async throws {
        let stub = StubCalendarLoader([
            .success(try result(["first"])), .failure(.offline), .success(try result(["second"])),
        ])
        let model = model(stub)

        await model.reload()
        await model.reload()

        #expect(model.events?.map(\.id) == ["first"])
        #expect(model.notice == .updateFailed)

        await model.reload()

        #expect(model.events?.map(\.id) == ["second"])
        #expect(model.notice == nil)
    }

    @Test func reloadsWhileOneRunsShareItsRequest() async throws {
        let gate = LoadGate()
        let fresh = try result(["fresh"])
        let model = NowComingUpModel(
            loader: { _ in
                await gate.enter()
                return fresh
            },
            today: { [today] in today })

        let first = Task { await model.reload() }
        while model.isLoading == false { await Task.yield() }
        let second = Task { await model.reload() }
        await gate.open()
        await first.value
        await second.value

        #expect(await gate.entries == 1)
        #expect(model.events?.map(\.id) == ["fresh"])
        #expect(model.isLoading == false)
    }
}

/// Answers calendar reads in order, repeating the last answer, and records
/// the Japan date each read starts on.
actor StubCalendarLoader {
    private var responses: [Result<CalendarReadResult, APIError>]
    private(set) var requests: [JapanDate] = []

    init(_ responses: [Result<CalendarReadResult, APIError>]) {
        self.responses = responses
    }

    func load(_ today: JapanDate) throws -> CalendarReadResult {
        requests.append(today)
        guard let next = responses.first else { throw APIError.offline }
        if responses.count > 1 {
            responses.removeFirst()
        }
        return try next.get()
    }
}

/// Set once from an observation's change handler, on any thread.
nonisolated final class ObservationFlag: Sendable {
    private let value = Mutex(false)
    func set() { value.withLock { $0 = true } }
    var isSet: Bool { value.withLock { $0 } }
}
