import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// What an edition's section shows as its own.
struct WorksEditionSummaryTests {
    private let shared = [WorksFixtures.track(no: 1), WorksFixtures.track(no: 2)]

    @Test func leavesOutTheTrackListEveryEditionShares() throws {
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", tracks: shared, editions: [WorksFixtures.edition(tracks: shared)])

        let summary = try #require(WorksEditionSummary.summaries(of: release).first)

        #expect(summary.tracks == nil)
    }

    @Test func showsATrackListThatDiffersFromTheSharedOne() throws {
        let longer = shared + [WorksFixtures.track(disc: 2, no: 1, discLabel: "DVD")]
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", tracks: shared,
            editions: [
                WorksFixtures.edition(name: "Limited", tracks: longer), WorksFixtures.edition(tracks: shared),
            ])

        let summaries = WorksEditionSummary.summaries(of: release)

        #expect(summaries.map(\.index) == [0, 1])
        #expect(summaries[0].tracks?.count == 3)
        #expect(summaries[1].tracks == nil)
    }

    @Test func anEditionWithoutTracksShowsNoList() throws {
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", tracks: shared, editions: [WorksFixtures.edition(tracks: [])])

        #expect(WorksEditionSummary.summaries(of: release)[0].tracks == nil)
    }

    @Test func showsDiscPhotosOnlyWhenTheyAreNotTheReleases() throws {
        let disc = WorksFixtures.discImage(1, "disc1.png")
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", discs: [disc],
            editions: [
                WorksFixtures.edition(discs: [disc]),
                WorksFixtures.edition(discs: [disc, WorksFixtures.discImage(2, "disc2.png")]),
            ])

        let summaries = WorksEditionSummary.summaries(of: release)

        #expect(summaries[0].discs.isEmpty)
        #expect(summaries[1].discs.map(\.disc) == [1, 2])
    }

    @Test func factsListWhatTheRecordStatesInOrder() throws {
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04",
            editions: [
                WorksFixtures.edition(
                    catalog: "EXAM-1", price: "¥3,000", format: "CD+DVD", packaging: "Sleeve",
                    date: "2020-04-01",
                    jan: "4900000000000"),
                WorksFixtures.edition(format: "CD"),
            ])

        let summaries = WorksEditionSummary.summaries(of: release)

        #expect(summaries[0].facts.map(\.kind) == [.catalog, .price, .format, .packaging, .released, .jan])
        #expect(summaries[0].facts.last?.value == .plain("4900000000000"))
        #expect(summaries[0].facts[4].value == .date(JapanDate(year: 2020, month: 4, day: 1)))
        // No catalog, price, packaging or date, and an empty JAN: only the format remains.
        #expect(summaries[1].facts.map(\.kind) == [.format])
    }

    @Test func aFactWithoutTextInAnyLanguageIsLeftOut() {
        #expect(WorksFact.localized(.label, LocalizedText()) == nil)
        #expect(WorksFact.localized(.label, LocalizedText(en: "")) == nil)
        #expect(WorksFact.localized(.label, nil) == nil)
        #expect(WorksFact.plain(.event, "") == nil)
        #expect(WorksFact.plain(.event, nil) == nil)
        #expect(WorksFact.plain(.event, "Example Market")?.value == .plain("Example Market"))
    }
}
