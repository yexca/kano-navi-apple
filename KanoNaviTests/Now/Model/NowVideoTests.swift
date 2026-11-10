import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowVideoTests {
    @Test func companionVideoTakesPrecedenceOverTheLatestVideo() throws {
        var fixture = DashboardFixture()
        fixture.events = [DashboardFixture.event(id: "E1", startsOn: "2026-11-12")]
        fixture.videos = [DashboardFixture.video(id: "C1", publishedAt: "2026-11-08T10:00:00Z")]
        fixture.latestVideo = DashboardFixture.video(id: "L1", publishedAt: "2026-11-09T10:00:00Z")
        fixture.spotlight = DashboardFixture.spotlight(eventID: "E1", companionVideoID: "C1")
        let dashboard = try fixture.dashboard()

        let video = NowVideo.latest(in: dashboard, besides: NowSpotlight(dashboard: dashboard))

        #expect(video?.id == "C1")
    }

    @Test func latestVideoIsSkippedWhenTheSpotlightShowsIt() throws {
        var fixture = DashboardFixture()
        fixture.latestVideo = DashboardFixture.video(id: "L1", publishedAt: "2026-11-09T10:00:00Z")
        fixture.spotlight = DashboardFixture.spotlight(mode: "latest")
        let dashboard = try fixture.dashboard()

        let video = NowVideo.latest(in: dashboard, besides: NowSpotlight(dashboard: dashboard))

        #expect(video == nil)
    }

    @Test func latestVideoShowsBesideAnotherTicket() throws {
        var fixture = DashboardFixture()
        fixture.videos = [DashboardFixture.video(id: "N1", scheduledAt: "2026-11-12T10:00:00Z")]
        fixture.latestVideo = DashboardFixture.video(
            id: "L1", source: "bilibili", publishedAt: "2026-11-09T10:00:00Z")
        fixture.spotlight = DashboardFixture.spotlight(videoID: "N1")
        let dashboard = try fixture.dashboard()

        let video = try #require(NowVideo.latest(in: dashboard, besides: NowSpotlight(dashboard: dashboard)))

        #expect(video.id == "L1")
        #expect(video.platform == .bilibili)
        #expect(video.publishedAt == (try DashboardFixture.instant("2026-11-09T10:00:00Z")))
    }
}
