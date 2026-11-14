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

    @Test func videosOnAirLeadAheadOfLaterReservations() throws {
        let cards = try [
            card("U1", phase: "upcoming", scheduledAt: "2026-11-15T10:00:00Z"),
            card("S1", phase: "started", scheduledAt: "2026-11-14T08:00:00Z"),
            card("L1", phase: "live", scheduledAt: "2026-11-14T07:00:00Z"),
            card("P1", publishedAt: "2026-11-10T10:00:00Z"),
        ]

        let lifted = VideoTimelineSection.grouping(cards, liftsOnAir: true)
        let plain = VideoTimelineSection.grouping(cards)

        #expect(lifted.map(\.id) == ["on-air", "2026-11"])
        #expect(lifted.map { $0.cards.map(\.id) } == [["S1", "L1"], ["U1", "P1"]])
        #expect(plain.map(\.id) == ["2026-11"])
        #expect(plain.flatMap(\.cards).map(\.id) == ["U1", "S1", "L1", "P1"])
    }

    @Test func noVideoOnAirAddsNoSection() throws {
        let sections = VideoTimelineSection.grouping(
            [try card("P1", publishedAt: "2026-11-10T10:00:00Z")], liftsOnAir: true)

        #expect(sections.map(\.id) == ["2026-11"])
    }

    @Test func topIsTheFirstSectionWithAVideoOnScreenWhateverTheReportedOrder() throws {
        let sections = VideoTimelineSection.grouping(
            try [
                card("L1", phase: "live", scheduledAt: "2026-11-14T07:00:00Z"),
                card("N1", publishedAt: "2026-11-10T10:00:00Z"),
                card("O1", publishedAt: "2026-10-05T10:00:00Z"),
            ], liftsOnAir: true)
        let slot = { (section: String, card: String) in TimelineSlot(sectionID: section, itemID: card) }

        #expect(
            VideoTimelineSection.topID(of: sections, visible: [slot("2026-10", "O1"), slot("2026-11", "N1")])
                == "2026-11")
        #expect(VideoTimelineSection.topID(of: sections, visible: [slot("on-air", "L1")]) == "on-air")
        #expect(VideoTimelineSection.topID(of: sections, visible: [slot("2026-09", "X")]) == nil)
        #expect(VideoTimelineSection.topID(of: sections, visible: []) == nil)
    }

    private func card(
        _ id: String, phase: String = "past", scheduledAt: String? = nil, publishedAt: String? = nil
    ) throws -> VideoCard {
        VideoCard(
            video: try VideoFixtures.video(
                VideoFixtures.json(id: id, phase: phase, scheduledAt: scheduledAt, publishedAt: publishedAt)))
    }
}
