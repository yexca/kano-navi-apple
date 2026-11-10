import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowSpotlightTests {
    @Test func dashboardWithoutSpotlightHasNoTicket() throws {
        let dashboard = try DashboardFixture().dashboard()

        #expect(NowSpotlight(dashboard: dashboard) == nil)
    }

    @Test func spotlightNamingMissingRecordsHasNoTicket() throws {
        var fixture = DashboardFixture()
        fixture.spotlight = DashboardFixture.spotlight(eventID: "missing", videoID: "missing")

        #expect(NowSpotlight(dashboard: try fixture.dashboard()) == nil)
    }

    @Test func videoTicketJoinsItsEntryAndAddsLinksOnOtherPlatforms() throws {
        var fixture = DashboardFixture()
        fixture.videos = [DashboardFixture.video(id: "V1", scheduledAt: "2026-11-10T12:00:00Z")]
        fixture.events = [
            DashboardFixture.event(
                id: "youtube-V1", startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z",
                links: [
                    DashboardFixture.link("youtube", "https://example.com/watch/V1"),
                    DashboardFixture.link("bilibili", "https://example.com/room", live: true),
                ]
            )
        ]
        fixture.spotlight = DashboardFixture.spotlight(
            eventID: "youtube-V1", videoID: "V1", isLive: true, membersChip: true)

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.mode == .next)
        #expect(spotlight.isLive)
        #expect(spotlight.showsMembersChip)
        #expect(spotlight.videoID == "V1")
        #expect(spotlight.eventID == "youtube-V1")
        #expect(spotlight.startsAt == (try DashboardFixture.instant("2026-11-10T12:00:00Z")))
        #expect(spotlight.links.map(\.destination) == [.platform(.youtube), .platform(.bilibili)])
        #expect(spotlight.links.map(\.isLive) == [true, true])
    }

    @Test func unannouncedBroadcastLeadsWhenTheProjectionSaysSo() throws {
        var fixture = DashboardFixture()
        fixture.videos = [DashboardFixture.video(id: "V1", scheduledAt: "2026-11-10T12:00:00Z")]
        fixture.liveNow = [
            "platform": "bilibili", "url": "https://example.com/live", "title": "Unannounced",
            "startedAt": "2026-11-10T09:00:00Z",
        ]
        fixture.spotlight = DashboardFixture.spotlight(videoID: "V1", liveNow: true, isLive: true)

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.mode == .liveNow)
        #expect(spotlight.title.original == "Unannounced")
        #expect(spotlight.links.map(\.destination) == [.platform(.bilibili)])
    }

    @Test func liveNowFlagWithoutBroadcastFallsBackToTheVideo() throws {
        var fixture = DashboardFixture()
        fixture.videos = [DashboardFixture.video(id: "V1", scheduledAt: "2026-11-10T12:00:00Z")]
        fixture.spotlight = DashboardFixture.spotlight(videoID: "V1", liveNow: true)

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.mode == .next)
        #expect(spotlight.videoID == "V1")
    }

    @Test func latestModeShowsTheLatestVideo() throws {
        var fixture = DashboardFixture()
        fixture.latestVideo = DashboardFixture.video(id: "L1", publishedAt: "2026-11-09T10:00:00Z")
        fixture.spotlight = DashboardFixture.spotlight(mode: "latest")

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.mode == .latest)
        #expect(spotlight.videoID == "L1")
        #expect(spotlight.showsMembersChip == false)
    }

    @Test func entryTicketLinksItsPlatformsThenItsAnnouncement() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "E1", startsOn: "2026-11-12",
                links: [
                    DashboardFixture.link("other", "https://www.example.com/page"),
                    DashboardFixture.link("bilibili", nil),
                ],
                url: "https://example.com/announcement"
            )
        ]
        fixture.spotlight = DashboardFixture.spotlight(eventID: "E1")

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.startsAt == nil)
        #expect(spotlight.startsOn == JapanDate(year: 2026, month: 11, day: 12))
        #expect(spotlight.links.map(\.destination) == [.site(host: "example.com"), .announcement])
    }

    @Test func announcementThatIsAlsoAPlatformLinkIsNotRepeated() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "E1", startsOn: "2026-11-12", startsAt: "2026-11-12T10:00:00Z",
                links: [DashboardFixture.link("youtube", "https://example.com/watch/E1")],
                url: "https://example.com/watch/E1"
            )
        ]
        fixture.spotlight = DashboardFixture.spotlight(eventID: "E1")

        let spotlight = try #require(NowSpotlight(dashboard: try fixture.dashboard()))

        #expect(spotlight.links.map(\.destination) == [.platform(.youtube)])
    }
}
