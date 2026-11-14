import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoTimelineSectionTests {
    @Test func videosAreGroupedByTheirJapanMonthInOrder() throws {
        let cards = try [
            card("D1", scheduledAt: "2026-12-02T11:00:00Z"),
            card("N1", publishedAt: "2026-11-20T10:00:00Z"),
            card("N2", publishedAt: "2026-11-01T03:00:00Z"),
            card("O1", publishedAt: "2026-10-05T10:00:00Z"),
        ]

        let sections = VideoTimelineSection.grouping(cards)

        #expect(sections.map(\.id) == ["2026-12", "2026-11", "2026-10"])
        #expect(sections.map { $0.cards.map(\.id) } == [["D1"], ["N1", "N2"], ["O1"]])
    }

    @Test func monthFollowsJapanTimeNotUTC() throws {
        // 2026-10-31 16:00 UTC is November 1 at 01:00 in Japan.
        let sections = VideoTimelineSection.grouping([try card("V", publishedAt: "2026-10-31T16:00:00Z")])

        #expect(sections.map(\.id) == ["2026-11"])
    }

    @Test func aMonthMetAgainJoinsItsFirstSection() throws {
        let cards = try [
            card("N1", publishedAt: "2026-11-20T10:00:00Z"),
            card("O1", publishedAt: "2026-10-05T10:00:00Z"),
            card("N2", publishedAt: "2026-11-01T10:00:00Z"),
        ]

        let sections = VideoTimelineSection.grouping(cards)

        #expect(sections.map { $0.cards.map(\.id) } == [["N1", "N2"], ["O1"]])
    }

    @Test func aVideoWithoutATimeStaysWithTheOneBefore() throws {
        let cards = try [
            card("N1", publishedAt: "2026-11-20T10:00:00Z"), card("U", publishedAt: nil),
        ]

        let sections = VideoTimelineSection.grouping(cards)

        #expect(sections.map { $0.cards.map(\.id) } == [["N1", "U"]])
    }

    private func card(_ id: String, scheduledAt: String? = nil, publishedAt: String? = nil) throws
        -> VideoCard
    {
        VideoCard(
            video: try VideoFixtures.video(
                VideoFixtures.json(id: id, scheduledAt: scheduledAt, publishedAt: publishedAt)))
    }
}
