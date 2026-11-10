import KanoNaviCore
import Testing

@testable import KanoNavi

struct JapanDateMonthTests {
    @Test(arguments: [
        ("2026-12-15", 1, "2027-01-01"),
        ("2026-01-31", -1, "2025-12-01"),
        ("2026-11-10", 0, "2026-11-01"),
        ("2026-11-10", 14, "2028-01-01"),
    ])
    func addingMonthsLandsOnTheFirstDay(start: String, months: Int, expected: String) throws {
        let date = try #require(JapanDate(rawValue: start))

        #expect(date.addingMonths(months).rawValue == expected)
    }

    @Test func sameMonthComparesYearAndMonth() {
        let date = JapanDate(year: 2026, month: 11, day: 10)

        #expect(date.isInSameMonth(as: JapanDate(year: 2026, month: 11, day: 30)))
        #expect(date.isInSameMonth(as: JapanDate(year: 2025, month: 11, day: 10)) == false)
    }
}
