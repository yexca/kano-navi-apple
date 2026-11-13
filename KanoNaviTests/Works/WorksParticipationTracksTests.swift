import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// How a participation work lists the tracks Kano took part in.
struct WorksParticipationTracksTests {
    @Test func separatesKanosTracksWhenTheWorkHasOthersToo() throws {
        let work = try WorksFixtures.participation(
            id: "w",
            tracks: [
                WorksFixtures.participationTrack(disc: 1, no: 1),
                WorksFixtures.participationTrack(disc: 2, no: 4, kano: true, credits: ["lyrics", "mystery"]),
                WorksFixtures.participationTrack(disc: 2, no: 5),
            ])

        let tracks = WorksParticipationTracks(work)

        #expect(tracks.separatesKanoTracks)
        #expect(tracks.isMultiDisc)
        #expect(tracks.kano.map(\.no) == [4])
        #expect(tracks.kano[0].kanoCredits == [.lyrics, .unknown("mystery")])
        #expect(tracks.total == 3)
        #expect(tracks.discs.map(\.disc) == [1, 2])
    }

    @Test func oneListSaysItAllWhenEveryTrackIsKanos() throws {
        let work = try WorksFixtures.participation(
            id: "w", tracks: [WorksFixtures.participationTrack(no: 1, kano: true)])

        let tracks = WorksParticipationTracks(work)

        #expect(tracks.separatesKanoTracks == false)
        #expect(tracks.isMultiDisc == false)
    }

    @Test func oneListWhenNoTrackIsMarkedAsKanos() throws {
        let work = try WorksFixtures.participation(
            id: "w", roles: ["lyrics"],
            tracks: [WorksFixtures.participationTrack(no: 1), WorksFixtures.participationTrack(no: 2)])

        let tracks = WorksParticipationTracks(work)

        #expect(tracks.kano.isEmpty)
        #expect(tracks.separatesKanoTracks == false)
    }

    @Test func unknownFieldsOfARecordDecodeAsEmptyOrNil() throws {
        let work = try WorksFixtures.participation(id: "w")

        #expect(work.unit == nil)
        #expect(work.label.isEmpty)
        #expect(WorksFact.plain(.label, work.label) == nil)
        #expect(WorksFact.plain(.event, work.event) == nil)
        #expect(WorksFact.plain(.catalog, work.catalog) == nil)
    }

    @Test func groupsByYearNewestFirst() throws {
        let works = [
            try WorksFixtures.participation(id: "a", date: "2011-05-01"),
            try WorksFixtures.participation(id: "b", date: "2011-12-31"),
            try WorksFixtures.participation(id: "c", date: "2026-10-25"),
        ]

        let groups = WorksYearGroup.groups(of: works, order: .newestFirst, date: \.date)

        #expect(groups.map(\.year) == [2026, 2011])
        #expect(groups[1].items.map(\.id) == ["b", "a"])
    }
}
