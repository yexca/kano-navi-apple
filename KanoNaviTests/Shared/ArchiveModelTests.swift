import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct ArchiveModelTests {
    private typealias F = ArchiveFixtures

    private func model(_ stub: StubArchiveLoader<String>) -> ArchiveModel<String> {
        ArchiveModel(
            months: { try await stub.months() }, page: { query in try await stub.page(query) },
            itemID: { $0 })
    }

    @Test func firstLoadSelectsTheNewestMonthAndReadsItsFirstPage() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())], pages: [F.query(): [.success(F.page(["a", "b"]))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.months == [F.november, F.october])
        #expect(model.selectedMonth == F.november)
        #expect(model.items == ["a", "b"])
        #expect(model.notice == nil)
    }

    @Test func monthRangeCoversTheWholeJapanMonth() throws {
        let february = try #require(ArchiveMonthKey(rawValue: "2028-02"))

        #expect(february.first == JapanDate(year: 2028, month: 2, day: 1))
        #expect(february.last == JapanDate(year: 2028, month: 2, day: 29))
        #expect(F.november.last == JapanDate(year: 2026, month: 11, day: 30))
        #expect(ArchiveMonthKey(rawValue: "2026-11-01") == nil)
        #expect(ArchiveMonthKey(rawValue: "2026-13") == nil)
    }

    @Test func loadMoreAppendsTheNextPageWithoutRepeatingItems() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [
                F.query(): [.success(F.page(["a", "b"], hasNext: true, total: 4))],
                F.query(page: 2): [.success(F.page(["b", "c", "d"], page: 2, total: 4))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()
        #expect(model.canLoadMore)
        await model.loadMore()

        #expect(model.items == ["a", "b", "c", "d"])
        #expect(model.canLoadMore == false)
        await model.loadMore()
        #expect(await stub.pageRequests.count == 2)
    }

    @Test func filterReadsItsOwnPagesAndKeepsTheMonthCounts() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [
                F.query(): [.success(F.page(["a", "b", "c", "d", "e"]))],
                F.query(filter: "game"): [.success(F.page(["a"]))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()
        model.filter = "game"
        await model.loadIfNeeded()

        #expect(model.items == ["a"])
        #expect(model.counts == ["game": 1, "talk": 4])
        #expect(model.allCount == 5)
        model.filter = nil
        #expect(model.items == ["a", "b", "c", "d", "e"])
    }

    @Test func countsComeFromTheIndexBeforeTheMonthLoads() async {
        let stub = StubArchiveLoader<String>(months: [.success(F.index())])
        let model = model(stub)

        await model.loadIfNeeded()
        model.selectedMonth = F.october

        #expect(model.counts == ["game": 2])
        #expect(model.allCount == 2)
    }

    @Test func failedRefreshKeepsTheItemsAndSaysSo() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [F.query(): [.success(F.page(["a"])), .failure(.http(status: 503))]])
        let model = model(stub)

        await model.loadIfNeeded()
        await model.refresh()

        #expect(model.items == ["a"])
        #expect(model.notice == .updateFailed)
    }

    @Test func failedFirstLoadSaysNothingCouldLoad() async {
        let stub = StubArchiveLoader<String>(
            months: [.success(F.index())], pages: [F.query(): [.failure(.offline)]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.listing == nil)
        #expect(model.notice == .loadFailed)
    }

    @Test func failedIndexWithNothingCachedSaysNothingCouldLoad() async {
        let model = model(StubArchiveLoader<String>(months: [.failure(.offline)]))

        await model.loadIfNeeded()

        #expect(model.selectedMonth == nil)
        #expect(model.notice == .loadFailed)
        #expect(model.isEmpty == false)
    }

    @Test func emptyIndexMeansNothingIsStored() async {
        let empty = ArchiveMonthIndex(months: [], isFromCache: false, fetchedAt: F.fetchedAt)
        let model = model(StubArchiveLoader<String>(months: [.success(empty)]))

        await model.loadIfNeeded()

        #expect(model.isEmpty)
        #expect(model.notice == nil)
    }

    @Test func cachedPageIsMarkedWithItsFetchTime() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index(isFromCache: true))],
            pages: [F.query(): [.success(F.page(["a"], isFromCache: true))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.items == ["a"])
        #expect(model.notice == .saved(fetchedAt: F.cachedAt))
    }

    @Test func cachedLaterPageMarksTheListingWithTheOldestFetchTime() async {
        let older = Date(timeIntervalSince1970: 1_793_000_000)
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [
                F.query(): [.success(F.page(["a"], hasNext: true))],
                F.query(page: 2): [.success(F.page(["b"], page: 2, isFromCache: true, fetchedAt: older))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()
        #expect(model.notice == nil)
        await model.loadMore()

        #expect(model.items == ["a", "b"])
        #expect(model.notice == .saved(fetchedAt: older))
    }

    @Test func failedLaterPageKeepsTheItemsAndCanBeRetried() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [
                F.query(): [.success(F.page(["a"], hasNext: true))],
                F.query(page: 2): [.failure(.offline), .success(F.page(["b"], page: 2))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()
        await model.loadMore()
        #expect(model.items == ["a"])
        #expect(model.moreFailure as? APIError == .offline)
        #expect(model.notice == nil)

        await model.loadMore()
        #expect(model.items == ["a", "b"])
        #expect(model.moreFailure == nil)
    }

    @Test func refreshKeepsTheChosenMonthAndReadsTheFirstPageAgain() async {
        let stub = StubArchiveLoader(
            months: [.success(F.index())],
            pages: [
                F.query(): [.success(F.page(["new"]))],
                F.query(F.october): [.success(F.page(["old"])), .success(F.page(["old", "older"]))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()
        model.selectedMonth = F.october
        await model.loadIfNeeded()
        await model.refresh()

        #expect(model.selectedMonth == F.october)
        #expect(model.items == ["old", "older"])
    }

    @Test func cancelledReadIsNotAFailure() async {
        let stub = StubArchiveLoader<String>(
            months: [.success(F.index())], pages: [F.query(): [.failure(.cancelled)]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.notice == nil)
        #expect(model.listing == nil)
    }
}
