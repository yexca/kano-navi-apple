import Foundation
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

    @Test func monthTitleKeepsTheYearWhenAbbreviated() {
        let date = JapanDate(year: 2026, month: 11, day: 10)
        let english = Locale(identifier: "en_US")

        #expect(date.monthTitle(locale: english) == "November 2026")
        #expect(date.monthTitle(locale: english, abbreviated: true) == "Nov 2026")
        #expect(date.monthTitle(locale: Locale(identifier: "ja_JP"), abbreviated: true).contains("2026"))
    }

    @Test func monthWeekLayoutLeavesBlanksBeforeTheFirstAndAfterTheLast() {
        let november = JapanDate(year: 2026, month: 11, day: 10).monthWeekLayout

        #expect(november.count == 6)
        #expect(november.allSatisfy { $0.count == 7 })
        #expect(november[0].prefix(6).allSatisfy { $0 == nil })
        #expect(november[0][6] == JapanDate(year: 2026, month: 11, day: 1))
        #expect(november[5][0] == JapanDate(year: 2026, month: 11, day: 30))
        #expect(november[5].dropFirst().allSatisfy { $0 == nil })
        #expect(november.joined().compactMap(\.self).count == 30)
    }

    @Test func monthStartingOnMondayFillsFourWeeks() {
        let february = JapanDate(year: 2027, month: 2, day: 1).monthWeekLayout

        #expect(february.count == 4)
        #expect(february.joined().allSatisfy { $0 != nil })
    }

    @Test(arguments: [
        ("2026-11-01", 6), ("2026-11-02", 0), ("2027-02-01", 0), ("2024-02-29", 3), ("2000-01-01", 5),
        ("1999-12-31", 4),
    ])
    func mondayFirstColumnMatchesTheWeekday(_ raw: String, _ column: Int) throws {
        let date = try #require(JapanDate(rawValue: raw))

        #expect(date.mondayFirstColumn == column)
        #expect(date.isWeekend == (column >= 5))
    }

    @Test(arguments: [
        ("2024-02-01", 29), ("2026-02-01", 28), ("2100-02-01", 28), ("2000-02-01", 29), ("2026-11-01", 30),
        ("2026-12-01", 31),
    ])
    func monthLengthCountsLeapYears(_ raw: String, _ days: Int) throws {
        #expect(try #require(JapanDate(rawValue: raw)).daysInMonth == days)
    }
}
