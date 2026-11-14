import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoTimelineFilterTests {
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
        #expect(VideoCard(video: video).shownFormCode == .short)
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

    @Test func noChoiceShowsEveryVideoAsItIs() throws {
        let cards = try Self.cards()

        #expect(VideoTimelineFilter().isActive == false)
        #expect(cards.compactMap(VideoTimelineFilter().apply) == cards)
    }

    @Test(arguments: [
        (VideoShelfKind.streams, ["R1", "A1"]), (.videos, ["W1", "W2"]), (.shorts, ["S1"]),
    ])
    func kindKeepsItsVideosInOrder(kind: VideoShelfKind, ids: [String]) throws {
        let filter = VideoTimelineFilter(kind: kind)

        #expect(filter.isActive)
        #expect(try Self.cards().compactMap(filter.apply).map(\.id) == ids)
    }

    @Test func aVideoIsOnItsOwnPlatformAndItsAlternates() throws {
        let filter = VideoTimelineFilter(platform: .bilibili)

        #expect(try Self.cards().compactMap(filter.apply).map(\.id) == ["W1", "A1"])
    }

    @Test func chosenPlatformsLinkComesFirst() throws {
        let shown = try Self.cards().compactMap(VideoTimelineFilter(platform: .bilibili).apply)

        #expect(shown.first?.links.map(\.destination) == [.platform(.bilibili), .platform(.youtube)])
        #expect(shown.last?.links.map(\.destination) == [.platform(.bilibili)])
    }

    @Test func kindAndPlatformCombine() throws {
        let filter = VideoTimelineFilter(kind: .streams, platform: .bilibili)

        #expect(try Self.cards().compactMap(filter.apply).map(\.id) == ["A1"])
    }

    /// A work on YouTube and Bilibili, a stream reservation, a premiere, a
    /// Bilibili stream archive and a Short.
    private static func cards() throws -> [VideoCard] {
        try [
            VideoFixtures.json(
                id: "W1", alternates: [["source": "bilibili", "url": "https://example.com/bili/W1"]]),
            VideoFixtures.json(id: "R1", phase: "upcoming", formCode: "upcoming", kind: "stream"),
            VideoFixtures.json(id: "W2", formCode: "premiere"),
            VideoFixtures.json(id: "A1", source: "bilibili", formCode: "archive"),
            VideoFixtures.json(id: "S1", formCode: "short", isShort: true),
        ].map { VideoCard(video: try VideoFixtures.video($0)) }
    }
}
