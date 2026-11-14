import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// How the Releases screen groups, orders and filters the personal releases.
struct WorksReleaseShelfTests {
    private let shelf: WorksReleaseShelf

    init() throws {
        // The collection's order: oldest first.
        shelf = WorksReleaseShelf(releases: [
            try WorksFixtures.release(id: "a", date: "2019-03-01", format: "single"),
            try WorksFixtures.release(id: "b", date: "2019-11-20", format: "album"),
            try WorksFixtures.release(id: "c", date: "2019-11-20", format: "doujin"),
            try WorksFixtures.release(id: "d", date: "2021-01-05", format: "single", digital: true),
            try WorksFixtures.release(id: "e", date: "2022-07-07", format: "cassette"),
        ])
    }

    @Test func groupsByJapanYearNewestFirst() {
        let groups = shelf.groups(format: nil, order: .newestFirst)

        #expect(groups.map(\.year) == [2022, 2021, 2019])
        #expect(groups.map { $0.items.map(\.id) } == [["e"], ["d"], ["c", "b", "a"]])
    }

    @Test func oldestFirstKeepsTheCollectionsOrder() {
        let groups = shelf.groups(format: nil, order: .oldestFirst)

        #expect(groups.map(\.year) == [2019, 2021, 2022])
        #expect(groups.flatMap(\.items).map(\.id) == ["a", "b", "c", "d", "e"])
    }

    @Test func ordersByDateEvenWhenTheListIsNot() throws {
        let unordered = WorksReleaseShelf(releases: [
            try WorksFixtures.release(id: "late", date: "2020-12-01"),
            try WorksFixtures.release(id: "early", date: "2020-01-15"),
        ])

        #expect(
            unordered.groups(format: nil, order: .oldestFirst).flatMap(\.items).map(\.id) == [
                "early", "late",
            ])
    }

    @Test func narrowsToAFormatAndDropsEmptyYears() {
        let singles = shelf.groups(format: "single", order: .newestFirst)

        #expect(singles.map(\.year) == [2021, 2019])
        #expect(singles.flatMap(\.items).map(\.id) == ["d", "a"])
    }

    @Test func aFormatTheAppDoesNotNameFallsUnderOther() {
        let other = shelf.groups(format: WorksCodeFilter.otherCode, order: .newestFirst)

        #expect(other.flatMap(\.items).map(\.id) == ["e"])
    }

    @Test func choicesCountEveryReleaseInAFixedOrder() {
        let options = shelf.options

        #expect(options.map(\.code) == [nil, "album", "single", "doujin", "other"])
        #expect(options.map(\.count) == [5, 1, 2, 1, 1])
    }

    @Test func marksLeadWithCancelledThenFormatDigitalAndUnit() throws {
        let release = try WorksFixtures.release(
            id: "x", date: "2022-10-07", format: "ep", digital: true, cancelled: true, unit: "Example Unit")
        let plain = try WorksFixtures.release(id: "y", date: "2022-10-07", unit: "")

        #expect(
            WorksReleaseMark.marks(for: release) == [
                .cancelled, .format(.ep), .digital, .unit("Example Unit"),
            ])
        #expect(WorksReleaseMark.marks(for: plain) == [.format(.album)])
    }
}
