import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// How track lists are grouped by disc and laid out as rows.
struct WorksTrackListTests {
    private func tracks(_ json: [[String: Any]]) throws -> [WorksTrack] {
        try WorksFixtures.decode([WorksTrack].self, json)
    }

    @Test func groupsTracksByDiscInNumberOrder() throws {
        let list = try tracks([
            WorksFixtures.track(disc: 2, no: 1, discLabel: "DVD"),
            WorksFixtures.track(disc: 1, no: 1),
            WorksFixtures.track(disc: 1, no: 2),
            WorksFixtures.track(disc: 2, no: 2),
        ])

        let discs = WorksTrackList.discs(of: list)

        #expect(discs.map(\.disc) == [1, 2])
        #expect(discs.map { $0.tracks.map(\.no) } == [[1, 2], [1, 2]])
        #expect(discs[0].label == nil)
        #expect(discs[1].label?.en == "DVD")
    }

    @Test func aDiscsLabelIsTheFirstOneItsTracksCarry() throws {
        let list = try tracks([
            WorksFixtures.track(disc: 1, no: 1),
            WorksFixtures.track(disc: 1, no: 2, discLabel: "Bonus CD"),
            WorksFixtures.track(disc: 1, no: 3, discLabel: "Other"),
        ])

        #expect(WorksTrackList.discs(of: list).first?.label?.en == "Bonus CD")
    }

    @Test func oneUnlabelledDiscHasNoHeading() throws {
        let list = try tracks([WorksFixtures.track(no: 1), WorksFixtures.track(no: 2)])

        let entries = WorksTrackList.entries(of: WorksTrackList.discs(of: list))

        #expect(entries.map(\.id) == [0, 1])
        #expect(entries.allSatisfy { if case .track = $0.content { true } else { false } })
    }

    @Test func severalDiscsEachGetAHeadingBeforeTheirTracks() throws {
        let list = try tracks([
            WorksFixtures.track(disc: 1, no: 1), WorksFixtures.track(disc: 2, no: 1, discLabel: "DVD"),
        ])

        let entries = WorksTrackList.entries(of: WorksTrackList.discs(of: list))

        #expect(entries.count == 4)
        #expect(entries[0].content == .disc(number: 1, label: nil))
        #expect(entries[2].content == .disc(number: 2, label: LocalizedText(en: "DVD")))
        #expect(entries.map(\.id) == [0, 1, 2, 3])
    }

    @Test func aLabelledSingleDiscGetsAHeading() throws {
        let list = try tracks([WorksFixtures.track(no: 1, discLabel: "Blu-ray")])

        let entries = WorksTrackList.entries(of: WorksTrackList.discs(of: list))

        #expect(entries.first?.content == .disc(number: 1, label: LocalizedText(en: "Blu-ray")))
    }

    @Test func anEmptyListHasNoRows() {
        #expect(WorksTrackList.entries(of: WorksTrackList.discs(of: [WorksTrack]())).isEmpty)
    }
}
