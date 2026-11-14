import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoTimelineModelTests {
    private typealias F = ArchiveFixtures

    @Test func firstLoadReadsTheNewestVideosAndTheMonthIndex() async throws {
        let stub = StubVideoTimelineLoader(
            months: [.success(F.index())], pages: [Self.query(): [.success(try Self.page(["N1", "O1"]))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.start == nil)
        #expect(model.index?.keys == [F.november, F.october])
        #expect(model.cards.map(\.id) == ["N1", "O1"])
        #expect(model.sections.map(\.id) == ["2026-11", "2026-10"])
        #expect(model.notice == nil)
        #expect(await stub.pageRequests == [Self.query()])
    }

    @Test func timelineDoesNotWaitForTheMonthIndex() async throws {
        let stub = StubVideoTimelineLoader(
            months: [.failure(.offline)], pages: [Self.query(): [.success(try Self.page(["N1"]))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.index == nil)
        #expect(model.cards.map(\.id) == ["N1"])
        #expect(model.notice == nil)
    }

    @Test func laterPagesAppendWithoutRepeatingVideos() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [.success(try Self.page(["N1", "N2"], hasNext: true))],
                Self.query(page: 2): [.success(try Self.page(["N2", "O1"], page: 2))],
            ])
        let model = model(stub)

        // Two videos are too few, so the first load reads on.
        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == ["N1", "N2", "O1"])
        #expect(model.canLoadMore == false)
        await model.loadMore()
        #expect(await stub.pageRequests.count == 2)
    }

    @Test func fillReadsOnUntilTheFilterShowsEnoughVideos() async throws {
        let many = (1...VideoTimelineModel.minimumShown).map { "B\($0)" }
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [.success(try Self.page(["N1", "N2"], hasNext: true))],
                Self.query(page: 2): [
                    .success(try Self.page(many, page: 2, source: "bilibili", hasNext: true))
                ],
                Self.query(page: 3): [.success(try Self.page(["O1"], page: 3))],
            ])
        let model = model(stub)
        model.filter = VideoTimelineFilter(platform: .bilibili)

        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == many)
        #expect(model.canLoadMore)
        #expect(await stub.pageRequests == [Self.query(), Self.query(page: 2)])
    }

    @Test func fillStopsAtTheEndOfTheTimeline() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [.success(try Self.page(["N1"], hasNext: true))],
                Self.query(page: 2): [.success(try Self.page(["O1"], page: 2))],
            ])
        let model = model(stub)
        model.filter = VideoTimelineFilter(kind: .shorts)

        await model.loadIfNeeded()

        #expect(model.cards.isEmpty)
        #expect(model.loadedCount == 2)
        #expect(model.canLoadMore == false)
        #expect(await stub.pageRequests.count == 2)
    }

    @Test func fillStopsAtAFailedPageAndKeepsTheVideos() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [.success(try Self.page(["N1"], hasNext: true))],
                Self.query(page: 2): [.failure(.offline)],
            ])
        let model = model(stub)
        model.filter = VideoTimelineFilter(kind: .shorts)

        await model.loadIfNeeded()

        #expect(model.moreFailure != nil)
        #expect(model.loadedCount == 1)
        #expect(model.canLoadMore)
        #expect(await stub.pageRequests.count == 2)
    }

    @Test func choosingAFilterLaterReadsOnForIt() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [.success(try Self.page(["N1"], hasNext: true))],
                Self.query(page: 2): [.success(try Self.page(["S1"], page: 2, formCode: "short"))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()
        // Without a filter one video is too few as well; it read on.
        #expect(model.loadedCount == 2)

        model.filter = VideoTimelineFilter(kind: .shorts)
        await model.fill()

        #expect(model.cards.map(\.id) == ["S1"])
        #expect(model.sections.first?.cards.first?.shownFormCode == .short)
    }

    @Test func monthJumpReadsFromThatMonthsLastDay() async throws {
        let stub = StubVideoTimelineLoader(
            months: [.success(F.index())],
            pages: [
                Self.query(): [.success(try Self.page(["N1"]))],
                Self.query(F.october): [.success(try Self.page(["O1"]))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        model.start = F.october
        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == ["O1"])
        let request = VideoTimelineSource.request(for: Self.query(F.october))
        #expect(request.until == JapanDate(year: 2026, month: 10, day: 31))

        model.start = nil
        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == ["N1"])
        #expect(await stub.pageRequests == [Self.query(), Self.query(F.october)])
    }

    @Test func newestRequestIsTheWholeTimeline() throws {
        let request = VideoTimelineSource.request(for: Self.query(page: 3))

        try request.validate()
        #expect(request.from == nil)
        #expect(request.to == nil)
        #expect(request.until == nil)
        #expect(request.page == 3)
        #expect(request.pageSize == VideoTimelineSource.pageSize)
        #expect(request.queryItems.map(\.name) == ["page", "pageSize"])
    }

    @Test func failedFirstLoadSaysSoWithNothingOnScreen() async {
        let stub = StubVideoTimelineLoader(pages: [Self.query(): [.failure(.offline)]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.listing == nil)
        #expect(model.notice == .loadFailed)
    }

    @Test func failedRefreshKeepsTheVideosOnScreen() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [Self.query(): [.success(try Self.page(["N1"])), .failure(.offline)]])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.refresh()

        #expect(model.cards.map(\.id) == ["N1"])
        #expect(model.notice == .updateFailed)
    }

    @Test func cachedPageSaysWhenItWasRead() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [Self.query(): [.success(try Self.page(["N1"], isFromCache: true))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.notice == .saved(fetchedAt: F.cachedAt))
    }

    @Test func refreshStartsAgainFromTheFirstPage() async throws {
        let stub = StubVideoTimelineLoader(
            pages: [
                Self.query(): [
                    .success(try Self.page(["N1"], hasNext: true)), .success(try Self.page(["N0", "N1"])),
                ],
                Self.query(page: 2): [.success(try Self.page(["O1"], page: 2))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()
        #expect(model.cards.map(\.id) == ["N1", "O1"])

        await model.refresh()

        #expect(model.cards.map(\.id) == ["N0", "N1"])
        #expect(model.canLoadMore == false)
        #expect(model.notice == nil)
    }

    @Test func aReadThatStartsWhileTheSameReadRunsWaitsForIt() async throws {
        let gate = TestGate()
        let stub = StubVideoTimelineLoader(pages: [Self.query(): [.success(try Self.page(["N1"]))]])
        await stub.hold(Self.query(), until: gate)
        let model = model(stub)

        async let first: Void = model.loadIfNeeded()
        async let second: Void = model.refresh()
        await gate.open()
        _ = await (first, second)

        #expect(model.cards.map(\.id) == ["N1"])
        #expect(await stub.pageRequests == [Self.query()])
    }

    private func model(_ stub: StubVideoTimelineLoader) -> VideoTimelineModel {
        VideoTimelineModel(
            months: { try await stub.months() }, page: { query in try await stub.page(query) })
    }

    private static func query(_ start: ArchiveMonthKey? = nil, page: Int = 1) -> VideoTimelineQuery {
        VideoTimelineQuery(start: start, page: page)
    }

    /// A page of videos, newest first. An ID starting with `N` or `B` is
    /// dated in November 2026, any other in October.
    private static func page(
        _ ids: [String], page: Int = 1, source: String = "youtube", formCode: String = "video",
        hasNext: Bool = false, isFromCache: Bool = false
    ) throws -> ArchivePage<Video> {
        let videos = try ids.map { id in
            let month = id.hasPrefix("N") || id.hasPrefix("B") ? "11" : "10"
            return try VideoFixtures.video(
                VideoFixtures.json(
                    id: id, source: source, formCode: formCode,
                    publishedAt: "2026-\(month)-09T10:00:00Z"))
        }
        return ArchivePage(
            items: videos, page: page, hasNext: hasNext, total: ids.count, counts: [:],
            isFromCache: isFromCache, fetchedAt: isFromCache ? F.cachedAt : F.fetchedAt)
    }
}
