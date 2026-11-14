import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoShelfFilterTests {
    @Test(arguments: [
        ("stream", VideoShelfKind.streams), ("archive", .streams), ("premiere", .videos), ("video", .videos),
        ("short", .shorts),
    ])
    func formGivesTheKind(formCode: String, kind: VideoShelfKind) throws {
        let video = try VideoFixtures.video(VideoFixtures.json(id: "V", formCode: formCode))

        #expect(VideoShelfKind(video: video) == kind)
    }

    @Test func shortFlagMakesAShortWhateverTheForm() throws {
        let video = try VideoFixtures.video(VideoFixtures.json(id: "V", formCode: "archive", isShort: true))

        #expect(VideoShelfKind(video: video) == .shorts)
    }

    @Test func reservationIsAStreamByItsKindOrTagContext() throws {
        let byKind = try VideoFixtures.video(
            VideoFixtures.json(id: "R1", phase: "upcoming", formCode: "upcoming", kind: "stream"))
        let byContext = try VideoFixtures.video(
            VideoFixtures.json(id: "R2", phase: "upcoming", formCode: "upcoming", tagContext: "stream"))
        let premiere = try VideoFixtures.video(
            VideoFixtures.json(id: "R3", phase: "upcoming", formCode: "upcoming", kind: "premiere"))

        #expect(VideoShelfKind(video: byKind) == .streams)
        #expect(VideoShelfKind(video: byContext) == .streams)
        #expect(VideoShelfKind(video: premiere) == .videos)
    }

    @Test func optionsListThePresentKindsWithCounts() throws {
        let shelf = try Self.shelf()

        let options = shelf.kindOptions(on: nil)

        #expect(options.map(\.code) == [nil, "streams", "videos", "shorts"])
        #expect(options.map(\.count) == [5, 2, 2, 1])
    }

    @Test func oneKindOffersNoKindFilter() throws {
        var fixture = DashboardFixture()
        fixture.videos = [VideoFixtures.json(id: "W1"), VideoFixtures.json(id: "W2")]
        fixture.shelf = VideoFixtures.shelf(lead: "W1", works: ["W2"])
        let shelf = VideoShelf(dashboard: try fixture.dashboard())

        #expect(shelf.kindOptions(on: nil).isEmpty)
        #expect(shelf.resolved(VideoShelfFilter(kind: .videos)).kind == nil)
    }

    @Test func platformCountsNarrowTheKindCounts() throws {
        let shelf = try Self.shelf()

        let options = shelf.kindOptions(on: .bilibili)

        #expect(options.map(\.code) == [nil, "streams", "videos"])
        #expect(options.map(\.count) == [2, 1, 1])
    }

    @Test func theSelectedKindStaysAtZeroOnAPlatform() throws {
        let shelf = try Self.shelf()

        let options = shelf.kindOptions(on: .bilibili, selected: .shorts)

        #expect(options.map(\.code) == [nil, "streams", "videos", "shorts"])
        #expect(options.map(\.count) == [2, 1, 1, 0])
    }

    @Test func aVideoIsOnItsOwnPlatformAndItsAlternates() throws {
        let shelf = try Self.shelf()

        #expect(shelf.platforms == [.youtube, .bilibili])
        #expect(shelf.narrowed(by: VideoShelfFilter(platform: .bilibili)).cards.map(\.id) == ["W1", "A1"])
    }

    @Test func kindKeepsTheGroupsOrderAndTheMatchingLead() throws {
        let shelf = try Self.shelf()

        let videos = shelf.narrowed(by: VideoShelfFilter(kind: .videos))
        let streams = shelf.narrowed(by: VideoShelfFilter(kind: .streams))

        #expect(videos.lead?.id == "W1")
        #expect(videos.leadIsFeatured)
        #expect(videos.works.map(\.id) == ["W2"])
        #expect(videos.reservations.isEmpty)
        #expect(streams.lead == nil)
        #expect(streams.leadIsFeatured == false)
        #expect(streams.reservations.map(\.id) == ["R1"])
        #expect(streams.archives.map(\.id) == ["A1"])
        #expect(streams.shorts.isEmpty)
    }

    @Test func chosenPlatformsLinkComesFirst() throws {
        let shelf = try Self.shelf()

        let narrowed = shelf.narrowed(by: VideoShelfFilter(platform: .bilibili))

        #expect(narrowed.lead?.links.first?.destination == .platform(.bilibili))
        #expect(narrowed.lead?.links.count == 2)
        #expect(narrowed.archives.first?.links.map(\.destination) == [.platform(.bilibili)])
    }

    @Test func aChoiceTheShelfNoLongerOffersIsAll() throws {
        var fixture = DashboardFixture()
        fixture.videos = [VideoFixtures.json(id: "W1"), VideoFixtures.json(id: "S1", formCode: "short")]
        fixture.shelf = VideoFixtures.shelf(works: ["W1"], shorts: ["S1"])
        let shelf = VideoShelf(dashboard: try fixture.dashboard())

        let resolved = shelf.resolved(VideoShelfFilter(kind: .streams, platform: .bilibili))

        #expect(resolved == VideoShelfFilter())
    }

    /// A featured work on YouTube and Bilibili, a stream reservation, a
    /// second work, a Bilibili stream archive and a Short.
    private static func shelf() throws -> VideoShelf {
        var fixture = DashboardFixture()
        fixture.videos = [
            VideoFixtures.json(
                id: "W1", alternates: [["source": "bilibili", "url": "https://example.com/bili/W1"]]),
            VideoFixtures.json(id: "R1", phase: "upcoming", formCode: "upcoming", kind: "stream"),
            VideoFixtures.json(id: "W2", formCode: "premiere"),
            VideoFixtures.json(id: "A1", source: "bilibili", formCode: "archive"),
            VideoFixtures.json(id: "S1", formCode: "short", isShort: true),
        ]
        fixture.shelf = VideoFixtures.shelf(
            lead: "W1", featured: true, reservations: ["R1"], works: ["W2"], archives: ["A1"], shorts: ["S1"])
        return VideoShelf(dashboard: try fixture.dashboard())
    }
}
