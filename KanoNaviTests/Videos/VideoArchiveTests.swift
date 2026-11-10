import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoArchiveTests {
    @Test func categoryFilterListsAllThenTheFourCategoriesWithCounts() {
        let options = VideoCategory.options(
            counts: ["game": 1, "talk": 2, "other": 5, "video": 1], allCount: 9)

        #expect(options.map(\.code) == [nil, "game", "talk", "song", "other"])
        #expect(options.map(\.count) == [9, 1, 2, 0, 5])
    }

    @Test func categoryCountsAreUnknownBeforeTheMonthLoads() {
        let options = VideoCategory.options(counts: [:], allCount: nil)

        #expect(options.allSatisfy { $0.count == nil })
    }

    @Test func monthPageRequestCoversTheMonthWithTheCategory() throws {
        let request = VideoArchiveSource.request(
            for: ArchiveQuery(month: ArchiveFixtures.november, filter: "song", page: 3))

        try request.validate()
        #expect(request.from == JapanDate(year: 2026, month: 11, day: 1))
        #expect(request.to == JapanDate(year: 2026, month: 11, day: 30))
        #expect(request.page == 3)
        #expect(request.pageSize == VideoArchiveSource.pageSize)
        #expect(request.category == "song")
    }

    @Test func monthIndexListsTheNewestMonthFirst() {
        let index = ArchiveMonthIndex(
            months: [
                ArchiveMonth(month: "2026-09", total: 1, counts: [:]),
                ArchiveMonth(month: "bad", total: 1, counts: [:]),
                ArchiveMonth(month: "2026-11", total: 1, counts: [:]),
            ], isFromCache: false, fetchedAt: ArchiveFixtures.fetchedAt)

        #expect(index.months.map(\.month) == ["2026-11", "2026-09"])
    }
}
