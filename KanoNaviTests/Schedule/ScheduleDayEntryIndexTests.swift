import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

/// A month's entries are indexed by day once, when it loads.
struct ScheduleDayEntryIndexTests {
    private let november = JapanDate(year: 2026, month: 11, day: 1)

    @Test func indexSortsEachDayAndKeepsOnlyTheMonthsDays() throws {
        let timed = try ScheduleFixtures.event(
            id: "timed", startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z")
        let early = try ScheduleFixtures.event(
            id: "early", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z")
        let dateOnly = try ScheduleFixtures.event(id: "date-only", startsOn: "2026-11-10")
        let nextMonth = try ScheduleFixtures.event(id: "next", startsOn: "2026-12-01")

        let index = ScheduleDayEntry.index(of: [timed, early, dateOnly, nextMonth], in: november)

        #expect(index.keys.sorted() == [JapanDate(year: 2026, month: 11, day: 10)])
        #expect(
            index[JapanDate(year: 2026, month: 11, day: 10)]?.map(\.event.id) == [
                "date-only", "early", "timed",
            ])
    }

    @Test func saleIsIndexedOnItsOpeningAndClosingDays() throws {
        let sale = try ScheduleFixtures.event(
            id: "sale", startsOn: "2026-11-10", startsAt: "2026-11-10T03:00:00Z", typeCode: "sale",
            calendarEntries: [
                [
                    "saleMark": "opens", "startsOn": "2026-11-10", "startsAt": "2026-11-10T03:00:00Z",
                    "timePrecision": "exact",
                ],
                [
                    "saleMark": "closes", "startsOn": "2026-11-12", "startsAt": "2026-11-12T09:00:00Z",
                    "timePrecision": "exact",
                ],
            ])

        let days = ScheduleMonthDays(month: november, events: [sale])

        #expect(days.entries(on: JapanDate(year: 2026, month: 11, day: 10)).map(\.id) == ["sale#0"])
        #expect(days.entries(on: JapanDate(year: 2026, month: 11, day: 12)).map(\.id) == ["sale#1"])
        #expect(days.entries(on: JapanDate(year: 2026, month: 11, day: 11)).isEmpty)
    }

    @Test func marksCarryTagsAndTitlesOnlyWhenAsked() throws {
        let release = try ScheduleFixtures.event(
            id: "Release day", startsOn: "2026-11-13", typeCode: "release")
        let days = ScheduleMonthDays(month: november, events: [release])
        let weeks = november.monthWeekLayout
        let day = JapanDate(year: 2026, month: 11, day: 13)

        let plain = ScheduleDayMark.marks(of: days, weeks: weeks)
        let titled = ScheduleDayMark.marks(
            of: days, weeks: weeks, titlesIn: .system, locale: Locale(identifier: "en_US"))

        #expect(plain[day]?.map(\.tag) == [.release])
        #expect(plain[day]?.first?.title == "")
        #expect(titled[day]?.first?.title == "Release day")
        #expect(ScheduleDayMark.marks(of: nil, weeks: weeks).isEmpty)
    }
}
