import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowFreshnessTests {
    @Test(
        arguments: [
            (nil, NowFreshness.State.waiting),
            (-60 * 60, .current),
            (-24 * 60 * 60 + 60, .current),
            (-25 * 60 * 60, .outOfDate),
            (2 * 60, .current),
            (10 * 60, .waiting),
        ] as [(TimeInterval?, NowFreshness.State)])
    func readTimeState(offset: TimeInterval?, expected: NowFreshness.State) {
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        #expect(NowFreshness.state(of: offset.map(now.addingTimeInterval), now: now) == expected)
    }

    @Test func sourcesAreListedInOrderAndMissingOnesWait() throws {
        var fixture = DashboardFixture()
        fixture.sourceFetchedAt = [
            "youtube": "2026-11-10T00:00:00Z",
            "x": "2026-11-08T00:00:00Z",
            "bilibili": NSNull(),
        ]
        let now = try DashboardFixture.instant("2026-11-10T01:00:00Z")

        let freshness = NowFreshness(meta: try fixture.dashboard().meta, now: now)

        #expect(freshness.sources.map(\.name) == [.x, .youtube, .bilibili, .shop])
        #expect(freshness.sources.map(\.state) == [.outOfDate, .current, .waiting, .waiting])
    }

    @Test func lastRunUsesItsFinishTimeElseItsStartTime() throws {
        var fixture = DashboardFixture()
        fixture.lastSync = ["status": "running", "startedAt": "2026-11-10T00:30:00Z"]
        let now = try DashboardFixture.instant("2026-11-10T01:00:00Z")

        let freshness = NowFreshness(meta: try fixture.dashboard().meta, now: now)

        #expect(freshness.syncAt == (try DashboardFixture.instant("2026-11-10T00:30:00Z")))
        #expect(freshness.syncState == .current)
        #expect(freshness.syncNeedsReview)
    }

    @Test(arguments: [("success", false), ("partial", false), ("ok", false), ("failed", true)])
    func runsOtherThanSuccessOrPartialNeedReview(status: String, needsReview: Bool) throws {
        var fixture = DashboardFixture()
        fixture.lastSync = ["status": status, "finishedAt": "2026-11-10T00:30:00Z"]

        let freshness = NowFreshness(meta: try fixture.dashboard().meta, now: .now)

        #expect(freshness.syncNeedsReview == needsReview)
    }
}
