import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

/// A List mode row shows its start over its end in Japan time, "All Day"
/// without a clock time, and names only notable states.
struct ScheduleDayRowModelTests {
    private let november = JapanDate(year: 2026, month: 11, day: 1)
    private let day = JapanDate(year: 2026, month: 11, day: 10)
    private let locale = Locale(identifier: "en_GB")

    private func row(_ event: ScheduleEvent, entry index: Int = 0) throws -> ScheduleDayRowModel {
        let days = ScheduleMonthDays(month: november, events: [event])
        let item = try #require(
            days.entries(on: event.displayCalendarEntries[index].startsOn).first {
                $0.id == "\(event.id)#\(index)"
            })
        return ScheduleDayRowModel(item, contentLanguage: .system, locale: locale)
    }

    @Test func timedEntryShowsItsStartAndItsEndOnTheSameDay() throws {
        let event = try ScheduleFixtures.event(
            id: "stream", startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z",
            endsAt: "2026-11-10T13:30:00Z")

        let row = try row(event)

        #expect(row.time == .clock(start: "20:00", end: "22:30"))
        #expect(row.isTimed)
        #expect(row.status == nil)
        #expect(row.tag == .stream)
    }

    @Test func endOnALaterDayShowsItsDate() throws {
        let event = try ScheduleFixtures.event(
            id: "overnight", startsOn: "2026-11-10", startsAt: "2026-11-10T13:00:00Z",
            endsAt: "2026-11-10T16:00:00Z")

        #expect(try row(event).time == .clock(start: "22:00", end: "11/11"))
    }

    @Test func dateOnlyEntryIsAllDay() throws {
        let event = try ScheduleFixtures.event(id: "release", startsOn: "2026-11-10", typeCode: "release")

        let row = try row(event)

        #expect(row.time == .allDay)
        #expect(row.isTimed == false)
        #expect(row.typeCode == "release")
    }

    @Test func saleEntryNamesItsMarkWithoutAnEnd() throws {
        let sale = try ScheduleFixtures.event(
            id: "sale", startsOn: "2026-11-10", startsAt: "2026-11-10T03:00:00Z",
            endsAt: "2026-11-12T09:00:00Z", state: "open", typeCode: "sale",
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

        let opens = try row(sale)
        let closes = try row(sale, entry: 1)

        #expect(opens.status == .sale(.opens))
        #expect(opens.time == .clock(start: "12:00", end: nil))
        #expect(closes.status == .sale(.closes))
        #expect(closes.time == .clock(start: "18:00", end: nil))
    }

    @Test(arguments: [
        ("live", ScheduleDayRowModel.Status?.some(.live)),
        ("cancelled", .some(.state(.cancelled))),
        ("pending", .some(.state(.pending))),
        ("cancellation_review", .some(.state(.cancellationReview))),
        ("upcoming", nil),
        ("done", nil),
    ])
    func onlyNotableStatesAreNamed(_ state: String, _ status: ScheduleDayRowModel.Status?) throws {
        let event = try ScheduleFixtures.event(
            id: state, startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z", state: state)

        #expect(try row(event).status == status)
    }

    @Test func doneAndCancelledRowsFadeAndCancelledIsStruckThrough() throws {
        let done = try row(ScheduleFixtures.event(id: "done", startsOn: "2026-11-10", state: "done"))
        let cancelled = try row(
            ScheduleFixtures.event(id: "cancelled", startsOn: "2026-11-10", state: "cancelled"))

        #expect(done.isFaded)
        #expect(done.isCancelled == false)
        #expect(cancelled.isFaded)
        #expect(cancelled.isCancelled)
    }
}
