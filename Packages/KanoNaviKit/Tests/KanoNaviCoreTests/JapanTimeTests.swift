import Foundation
import Testing

@testable import KanoNaviCore

struct JapanTimeTests {
    @Test func dateUsesTokyoAroundMidnight() throws {
        let before = try #require(KanoNaviDateCoding.date(from: "2026-11-09T14:59:59Z"))
        let after = try #require(KanoNaviDateCoding.date(from: "2026-11-09T15:00:00Z"))
        #expect(JapanDate.date(from: before).rawValue == "2026-11-09")
        #expect(JapanDate.date(from: after).rawValue == "2026-11-10")
    }

    @Test(arguments: ["2026-02-29", "2026-02-30", "2026-04-31"])
    func impossibleDayIsNotAJapanDate(raw: String) {
        #expect(JapanDate(rawValue: raw) == nil)
    }

    @Test func leapDayIsAJapanDate() {
        #expect(JapanDate(rawValue: "2024-02-29")?.day == 29)
    }

    @Test func monthGridStartsMondayAndHasSixWeeks() throws {
        let date = try #require(JapanDate(rawValue: "2026-11-01"))
        #expect(date.monthGrid.count == 42)
        #expect(date.monthGrid.first?.rawValue == "2026-10-26")
        #expect(date.monthGrid.last?.rawValue == "2026-12-06")
    }
}
