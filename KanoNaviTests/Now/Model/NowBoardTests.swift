import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowBoardTests {
    private let now = "2026-11-10T01:00:00Z"

    @Test func spotlightNamesItsEventAndItsVideosAddressesForComingUp() throws {
        var fixture = DashboardFixture()
        fixture.videos = [
            DashboardFixture.video(
                id: "V1", scheduledAt: "2026-11-10T12:00:00Z",
                alternates: [["source": "bilibili", "url": "https://example.com/bilibili/V1"]])
        ]
        fixture.events = [
            DashboardFixture.event(id: "stream-1", startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z")
        ]
        fixture.spotlight = DashboardFixture.spotlight(eventID: "stream-1", videoID: "V1")

        let board = NowBoard(dashboard: try fixture.dashboard(), now: try DashboardFixture.instant(now))

        #expect(board.shownAbove.eventIDs == ["stream-1"])
        #expect(
            board.shownAbove.videoURLs == [
                try #require(URL(string: "https://example.com/watch/V1")),
                try #require(URL(string: "https://example.com/bilibili/V1")),
            ])
    }

    @Test func boardWithoutSpotlightLeavesNothingOut() throws {
        let board = NowBoard(
            dashboard: try DashboardFixture().dashboard(), now: try DashboardFixture.instant(now))

        #expect(board.shownAbove == NowComingUp.ShownAbove())
    }
}
