import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

struct MonthGridTests {
    private static let today = JapanDate(year: 2026, month: 11, day: 15)

    private static func index(_ months: [String: Int]) -> ArchiveMonthIndex {
        ArchiveMonthIndex(
            months: months.map { ArchiveMonth(month: $0.key, total: $0.value, counts: [:]) },
            isFromCache: false, fetchedAt: ArchiveFixtures.fetchedAt)
    }

    @Test func yearsRunNewestFirstFromTheCurrentYearToTheOldestMonth() {
        let grid = MonthGrid(index: Self.index(["2024-03": 2, "2026-10": 5]), today: Self.today)

        #expect(grid.years.map(\.year) == [2026, 2025, 2024])
        #expect(grid.years.allSatisfy { $0.months.count == 12 })
        #expect(grid.years[0].months.map(\.month.rawValue).prefix(2) == ["2026-01", "2026-02"])
    }

    @Test func onlyPastAndCurrentMonthsWithItemsCanBeChosen() throws {
        let grid = MonthGrid(
            index: Self.index(["2026-09": 0, "2026-10": 5, "2026-11": 2, "2026-12": 1]), today: Self.today)
        let year = try #require(grid.years.first)

        let enabled = year.months.filter(\.isEnabled).map(\.month.rawValue)
        #expect(enabled == ["2026-10", "2026-11"])
        #expect(year.months[9].count == 5)
        // A future month stays dimmed even when it holds items, such as a
        // reservation.
        #expect(year.months[11].count == 1)
        #expect(year.months[11].isEnabled == false)
        #expect(year.months[0].count == 0)
    }

    @Test func emptyIndexHasNoYears() {
        #expect(MonthGrid(index: Self.index([:]), today: Self.today).years.isEmpty)
    }

    @Test func monthsWrittenInAnotherFormAreLeftOut() {
        let grid = MonthGrid(index: Self.index(["2026-1": 3, "2026-10": 1]), today: Self.today)

        #expect(grid.years.map(\.year) == [2026])
        #expect(grid.years[0].months.filter(\.isEnabled).map(\.month.rawValue) == ["2026-10"])
    }

    @Test func choiceIsNamedByItsMonthOrNewest() {
        let locale = Locale(identifier: "en_US")
        let october = ArchiveMonthKey(containing: JapanDate(year: 2026, month: 10, day: 1))

        #expect(MonthGrid.title(of: nil, locale: locale) == "Newest")
        #expect(MonthGrid.title(of: october, locale: locale) == "October 2026")
    }
}
