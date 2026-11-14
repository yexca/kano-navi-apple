import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostTimelineModelTests {
    private typealias F = ArchiveFixtures
    private typealias P = PostTimelineFixtures

    @Test func firstLoadReadsTheNewestPostsAndTheMonthIndex() async throws {
        let stub = StubPostTimelineLoader(
            months: [.success(F.index())], pages: [P.query(): [.success(try P.page(Self.ids(12)))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.start == nil)
        #expect(model.index?.keys == [F.november, F.october])
        #expect(model.cards.map(\.id) == Self.ids(12))
        #expect(model.notice == nil)
        #expect(await stub.pageRequests == [P.query()])
    }

    @Test func postsAreGroupedByTheirJapanMonth() async throws {
        let stub = StubPostTimelineLoader(pages: [P.query(): [.success(try P.page(["N1", "N2", "O1"]))]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.sections.map(\.id) == ["2026-11", "2026-10"])
        #expect(model.sections.map { $0.cards.map(\.id) } == [["N1", "N2"], ["O1"]])
    }

    @Test func startMonthReadsOnOrBeforeItsLastJapanDate() async throws {
        let stub = StubPostTimelineLoader(
            months: [.success(F.index())],
            pages: [
                P.query(): [.success(try P.page(Self.ids(12)))],
                P.query(F.october): [.success(try P.page(Self.ids(12, prefix: "O")))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        model.start = F.october
        await model.loadIfNeeded()

        #expect(model.cards.first?.id == "O1")
        let request = PostTimelineSource.request(for: P.query(F.october))
        #expect(request.until == JapanDate(year: 2026, month: 10, day: 31))

        // Each start keeps its own pages.
        model.start = nil
        await model.loadIfNeeded()

        #expect(model.cards.first?.id == "N1")
        #expect(await stub.pageRequests == [P.query(), P.query(F.october)])
    }

    @Test func accountIsTheAPIsFilterWithTheTimelinesCounts() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(Self.ids(12)))],
                P.query(account: "_sub"): [.success(try P.page(["N1", "O1"], handle: "_sub"))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        model.account = "_sub"
        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == ["N1", "O1"])
        #expect(model.counts == ["kano_example": 3, "_sub": 2])
        // All counts the timeline of every account.
        #expect(model.allCount == 12)
        #expect(PostTimelineSource.request(for: P.query(account: "_sub")).account == "_sub")
    }

    @Test func fillReadsOnUntilEnoughPostsAreShown() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(["N1", "N2"], hasNext: true))],
                P.query(page: 2): [.success(try P.page(Self.ids(10, prefix: "O"), page: 2, hasNext: true))],
                P.query(page: 3): [.success(try P.page(["O99"], page: 3))],
            ])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.cards.count == 12)
        #expect(model.canLoadMore)
        #expect(await stub.pageRequests == [P.query(), P.query(page: 2)])
    }

    @Test func loadMoreAppendsTheNextPage() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(Self.ids(12), hasNext: true))],
                P.query(page: 2): [.success(try P.page(["O1"], page: 2))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.loadMore()

        #expect(model.cards.map(\.id) == Self.ids(12) + ["O1"])
        #expect(model.canLoadMore == false)
        await model.loadMore()
        #expect(await stub.pageRequests == [P.query(), P.query(page: 2)])
    }

    @Test func aPostPushedOntoTheNextPageIsListedOnce() async throws {
        // A post published since page 1 was read moves N12 onto page 2; the
        // page is read at the same revision, so it is only appended.
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(Self.ids(12), hasNext: true))],
                P.query(page: 2): [.success(try P.page(["N12", "O1"], page: 2))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.loadMore()

        #expect(model.cards.map(\.id) == Self.ids(12) + ["O1"])
        #expect(await stub.pageRequests == [P.query(), P.query(page: 2)])
    }

    @Test func aPageOfANewerRevisionReadsTheLoadedPagesAgain() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [
                    .success(try P.page(Self.ids(12), hasNext: true)),
                    .success(try P.page(["N0"] + Self.ids(11), hasNext: true, revision: 2)),
                ],
                P.query(page: 2): [.success(try P.page(["N12", "O1"], page: 2, revision: 2))],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.loadMore()

        #expect(model.cards.map(\.id) == ["N0"] + Self.ids(12) + ["O1"])
        #expect(model.listing?.revision == 2)
        #expect(model.listing?.isMixed == false)
        #expect(
            await stub.pageRequests == [P.query(), P.query(page: 2), P.query(), P.query(page: 2)])
    }

    @Test func aNewRevisionReadsTheLoadedPagesAgainAndReplacesThem() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [
                    .success(try P.page(Self.ids(12), hasNext: true)),
                    // N3 was removed and N0 added.
                    .success(try P.page(Self.withoutN3, hasNext: true, revision: 2)),
                ],
                P.query(page: 2): [
                    .success(try P.page(["O1", "O2"], page: 2, hasNext: true)),
                    .success(try P.page(["O1", "O2"], page: 2, hasNext: true, revision: 2)),
                ],
            ])
        let model = model(stub)
        await model.loadIfNeeded()
        await model.loadMore()
        await stub.clearRequests()

        await model.reloadAfterChange(revision: 2)

        #expect(model.cards.map(\.id) == Self.withoutN3 + ["O1", "O2"])
        #expect(model.listing?.page == 2)
        #expect(model.notice == nil)
        #expect(await stub.pageRequests == [P.query(), P.query(page: 2)])
    }

    @Test func theRevisionOnScreenIsNotReadAgain() async throws {
        let stub = StubPostTimelineLoader(pages: [P.query(): [.success(try P.page(Self.ids(12)))]])
        let model = model(stub)
        await model.loadIfNeeded()
        await stub.clearRequests()

        await model.reloadAfterChange(revision: 1)

        #expect(await stub.pageRequests.isEmpty)
    }

    @Test func aNewRevisionOutdatesTheOtherTimelines() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(Self.ids(12)))],
                P.query(F.october): [
                    .success(try P.page(["O1"])), .success(try P.page(["O0", "O1"], revision: 2)),
                ],
            ])
        let model = model(stub)
        model.start = F.october
        await model.loadIfNeeded()
        model.start = nil
        await model.loadIfNeeded()

        await model.reloadAfterChange(revision: 2)
        model.start = F.october
        await model.loadIfNeeded()

        #expect(model.cards.map(\.id) == ["O0", "O1"])
    }

    @Test func theLoadedPostsStayUntilTheReadsReturn() async throws {
        let gate = TestGate()
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [
                    .success(try P.page(Self.ids(12))),
                    .success(try P.page(["N0"] + Self.ids(12), revision: 2)),
                ]
            ])
        let model = model(stub)
        await model.loadIfNeeded()
        await stub.hold(P.query(), until: gate)

        async let reload: Void = model.reloadAfterChange(revision: 2)
        while await stub.pageRequests.count < 2 {
            await Task.yield()
        }

        #expect(model.cards.map(\.id) == Self.ids(12))
        await gate.open()
        await reload
        #expect(model.cards.first?.id == "N0")
    }

    @Test func failedReadAgainKeepsThePostsOnScreen() async throws {
        let stub = StubPostTimelineLoader(
            pages: [P.query(): [.success(try P.page(Self.ids(12))), .failure(.offline)]])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.refresh()

        #expect(model.cards.map(\.id) == Self.ids(12))
        #expect(model.notice == .updateFailed)
    }

    @Test func failedLaterPageKeepsThePostsAndSaysSo() async throws {
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(Self.ids(12), hasNext: true))],
                P.query(page: 2): [.failure(.offline)],
            ])
        let model = model(stub)
        await model.loadIfNeeded()

        await model.loadMore()

        #expect(model.moreFailure != nil)
        #expect(model.cards.count == 12)
        #expect(model.canLoadMore)
        #expect(model.notice == nil)
    }

    @Test func failedFirstLoadSaysSoWithNothingOnScreen() async {
        let stub = StubPostTimelineLoader(pages: [P.query(): [.failure(.offline)]])
        let model = model(stub)

        await model.loadIfNeeded()

        #expect(model.listing == nil)
        #expect(model.notice == .loadFailed)
    }

    @Test func cachedNewestPageIsThereBeforeTheFirstRead() async throws {
        let stub = StubPostTimelineLoader(pages: [P.query(): [.success(try P.page(["N0", "N1"]))]])
        let model = PostTimelineModel(
            months: { try await stub.months() }, page: { query in try await stub.page(query) },
            cachedFirstPage: try P.page(["N1"], isFromCache: true))

        #expect(model.cards.map(\.id) == ["N1"])
        #expect(model.notice == nil)

        await model.loadIfNeeded()

        #expect(await stub.pageRequests == [P.query()])
        #expect(model.cards.map(\.id) == ["N0", "N1"])
        #expect(model.notice == nil)
    }

    @Test func cachedNewestPageIsCalledTheSavedCopyOnlyWhenTheReadFallsBack() async throws {
        let stub = StubPostTimelineLoader(
            pages: [P.query(): [.success(try P.page(["N1"], isFromCache: true))]])
        let model = PostTimelineModel(
            months: { try await stub.months() }, page: { query in try await stub.page(query) },
            cachedFirstPage: try P.page(["N1"], isFromCache: true))

        #expect(model.notice == nil)

        await model.loadIfNeeded()

        #expect(model.notice == .saved(fetchedAt: F.cachedAt))
    }

    @Test func avatarsComeFromThePageThenTheDashboard() async throws {
        let pageAvatar = try #require(URL(string: "https://example.com/media/account-avatar/x/kano_example"))
        let subAvatar = try #require(URL(string: "https://example.com/media/account-avatar/x/_sub"))
        let profile = try #require(URL(string: "https://example.com/media/profile"))
        let stub = StubPostTimelineLoader(
            pages: [
                P.query(): [.success(try P.page(["N1"], accountAvatars: ["x:kano_example": pageAvatar]))],
                P.query(account: "_sub"): [.success(try P.page(["N2"], handle: "_sub", accountAvatars: [:]))],
                P.query(account: "other"): [.success(try P.page(["N3"], handle: "other"))],
            ])
        let model = model(stub)
        model.avatarFallback = PostAvatarFallback(
            accountAvatars: ["x:kano_example": subAvatar, "x:_sub": subAvatar], profileAvatarURL: profile)

        await model.loadIfNeeded()
        #expect(model.cards.first?.avatar == .image(pageAvatar))

        model.account = "_sub"
        await model.loadIfNeeded()
        #expect(model.cards.first?.avatar == .image(subAvatar))

        // Kano's own post without an avatar entry shows the profile avatar,
        // also when the dashboard's avatars arrive later.
        model.account = "other"
        model.avatarFallback = PostAvatarFallback()
        await model.loadIfNeeded()
        #expect(model.cards.first?.avatar == .placeholder)
        model.avatarFallback = PostAvatarFallback(accountAvatars: nil, profileAvatarURL: profile)
        #expect(model.cards.first?.avatar == .image(profile))
    }

    @Test func aReadThatStartsWhileTheSameReadRunsWaitsForIt() async throws {
        let gate = TestGate()
        let stub = StubPostTimelineLoader(pages: [P.query(): [.success(try P.page(Self.ids(12)))]])
        await stub.hold(P.query(), until: gate)
        let model = model(stub)

        async let first: Void = model.loadIfNeeded()
        async let second: Void = model.refresh()
        await gate.open()
        _ = await (first, second)

        #expect(model.cards.count == 12)
        #expect(await stub.pageRequests == [P.query()])
    }

    private func model(_ stub: StubPostTimelineLoader) -> PostTimelineModel {
        PostTimelineModel(months: { try await stub.months() }, page: { query in try await stub.page(query) })
    }

    /// The first page of `ids(12)` after N3 was removed and N0 added.
    private static let withoutN3 = ["N0", "N1", "N2"] + ids(12).dropFirst(3)

    /// `count` post IDs, `N1` and on: enough that `fill()` reads no further.
    private static func ids(_ count: Int, prefix: String = "N") -> [String] {
        (1...count).map { prefix + String($0) }
    }
}
