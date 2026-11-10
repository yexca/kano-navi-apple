import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoCardTests {
    @Test(arguments: [
        ("live", VideoStatusMark.live), ("upcoming", .upcoming), ("started", .started),
        ("cancelled", .cancelled),
    ])
    func phaseGivesAStatusMarkInsteadOfTheForm(phase: String, mark: VideoStatusMark) throws {
        let card = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "V", phase: phase)))

        #expect(card.status == mark)
        #expect(card.shownFormCode == nil)
    }

    @Test func pastVideoShowsItsForm() throws {
        let card = VideoCard(
            video: try VideoFixtures.video(VideoFixtures.json(id: "V", phase: "past", formCode: "archive")))

        #expect(card.status == nil)
        #expect(card.shownFormCode == .archive)
    }

    @Test(arguments: [
        ("members", VideoAvailabilityMark?.some(.members)), ("private", .private), ("removed", .removed),
        ("public", nil), ("unlisted", nil), ("someday", nil),
    ])
    func availabilityIsMarkedOnlyWhenNotEveryoneCanWatch(code: String, mark: VideoAvailabilityMark?)
        throws
    {
        let card = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "V", availability: code)))

        #expect(card.availability == mark)
    }

    @Test func linksListTheOwnPageThenTheAlternates() throws {
        let json = VideoFixtures.json(
            id: "V", alternates: [["source": "bilibili", "url": "https://example.com/bili/V"]])

        let card = VideoCard(video: try VideoFixtures.video(json))

        #expect(card.links.map(\.destination) == [.platform(.youtube), .platform(.bilibili)])
        #expect(
            card.links.map(\.url.absoluteString) == [
                "https://example.com/watch/V", "https://example.com/bili/V",
            ])
    }

    @Test func liveVideosOwnLinkIsMarkedLive() throws {
        let card = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "V", phase: "live")))

        #expect(card.links.first?.isLive == true)
    }

    @Test func timeIsTheScheduledStartElseThePublication() throws {
        let scheduled = VideoCard(
            video: try VideoFixtures.video(
                VideoFixtures.json(id: "S", scheduledAt: "2026-11-12T12:00:00Z")))
        let published = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "P")))

        #expect(scheduled.time == (try DashboardFixture.instant("2026-11-12T12:00:00Z")))
        #expect(published.time == (try DashboardFixture.instant("2026-11-09T10:00:00Z")))
    }

    @Test func shortIsFoundByItsFormOrItsFlag() throws {
        let byForm = VideoCard(
            video: try VideoFixtures.video(VideoFixtures.json(id: "A", formCode: "short")))
        let byFlag = VideoCard(
            video: try VideoFixtures.video(VideoFixtures.json(id: "B", formCode: nil, isShort: true)))
        let video = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "C")))

        #expect(byForm.isShort)
        #expect(byFlag.isShort)
        #expect(video.isShort == false)
    }

    @Test(arguments: [(289, "4:49"), (7265, "2:01:05")])
    func lengthReadsLikeThePlatforms(seconds: Int, text: String) throws {
        let card = VideoCard(
            video: try VideoFixtures.video(VideoFixtures.json(id: "V", durationSeconds: seconds)))

        #expect(card.lengthText == text)
    }

    @Test func unknownLengthHasNoText() throws {
        let card = VideoCard(video: try VideoFixtures.video(VideoFixtures.json(id: "V")))

        #expect(card.lengthText == nil)
    }
}
