import Foundation
import KanoNaviCore
import Testing

@testable import KanoNaviComponents

struct EventTicketTimingTests {
    private func instant(_ value: String) throws -> Date {
        try #require(KanoNaviDateCoding.date(from: value))
    }

    private func timing(
        _ startsOn: String, at startsAt: String?, precision: String = "exact", state: String = "upcoming",
        saleMark: String? = nil, now: String
    ) throws -> EventTicketTiming {
        var entry: [String: Any] = [
            "startsOn": startsOn, "startsAt": startsAt as Any, "timePrecision": precision,
        ]
        entry["saleMark"] = saleMark
        let event = try SyntheticEvent.make(
            startsOn: startsOn, startsAt: startsAt, timePrecision: precision, state: state,
            calendarEntries: [entry])
        return EventTicketTiming(
            event: event, entry: event.displayCalendarEntries[0], now: try instant(now))
    }

    @Test func todayReadsAsAClockTime() throws {
        // 21:00 JST on Nov 10, read at 10:00 JST: eleven hours away, same day.
        let result = try timing("2026-11-10", at: "2026-11-10T12:00:00Z", now: "2026-11-10T01:00:00Z")

        #expect(result == .relativeTime(try instant("2026-11-10T12:00:00Z")))
    }

    @Test func soonAfterMidnightReadsAsAClockTime() throws {
        // 01:00 JST on Nov 11, read at 22:00 JST on Nov 10.
        let result = try timing("2026-11-11", at: "2026-11-10T16:00:00Z", now: "2026-11-10T13:00:00Z")

        #expect(result == .relativeTime(try instant("2026-11-10T16:00:00Z")))
    }

    @Test func laterDaysReadAsJapanDays() throws {
        // 21:00 JST on Nov 11 and Nov 14, read at 08:00 JST on Nov 10.
        let tomorrow = try timing("2026-11-11", at: "2026-11-11T12:00:00Z", now: "2026-11-09T23:00:00Z")
        let later = try timing("2026-11-14", at: "2026-11-14T12:00:00Z", now: "2026-11-09T23:00:00Z")

        #expect(tomorrow == .relativeDay(1))
        #expect(later == .relativeDay(4))
    }

    @Test func dateOnlyEntriesReadAsJapanDays() throws {
        // 23:30 JST on Nov 10: today in Japan although it is Nov 10 in UTC too.
        let today = try timing("2026-11-10", at: nil, precision: "date", now: "2026-11-10T14:30:00Z")
        // 00:30 JST on Nov 11 is still Nov 10 in UTC.
        let japanDay = try timing("2026-11-12", at: nil, precision: "date", now: "2026-11-10T15:30:00Z")

        #expect(today == .relativeDay(0))
        #expect(japanDay == .relativeDay(1))
    }

    @Test func liveEventIsLiveUntilItsEnd() throws {
        let event = try SyntheticEvent.make(
            startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z", state: "live")

        let result = EventTicketTiming(
            event: event, entry: event.displayCalendarEntries[0], now: try instant("2026-11-10T12:30:00Z"))

        #expect(result == .live(endsAt: nil))
    }

    @Test func saleEntryIsNeverLive() throws {
        let result = try timing(
            "2026-11-10", at: "2026-11-10T03:00:00Z", state: "live", saleMark: "opens",
            now: "2026-11-10T01:00:00Z")

        #expect(result == .relativeTime(try instant("2026-11-10T03:00:00Z")))
    }

    @Test(arguments: [
        (EventTicketTiming.relativeDay(0), "en", "today"),
        (.relativeDay(1), "en", "tomorrow"),
        (.relativeDay(4), "en", "in 4 days"),
        (.relativeDay(1), "ja", "明日"),
        (.relativeDay(1), "zh-Hans", "明天"),
    ])
    func dayPhrasesUseTheSystemFormatting(timing: EventTicketTiming, language: String, expected: String)
        throws
    {
        let now = try instant("2026-11-10T01:00:00Z")

        #expect(timing.relativeText(now: now, locale: Locale(identifier: language)) == expected)
    }

    @Test func clockPhrasesAreRelativeToNow() throws {
        let now = try instant("2026-11-10T01:00:00Z")
        let english = Locale(identifier: "en")

        #expect(
            EventTicketTiming.relativeTime(now.addingTimeInterval(3 * 60 * 60))
                .relativeText(now: now, locale: english) == "in 3 hours")
        #expect(
            EventTicketTiming.relativeTime(now.addingTimeInterval(-2 * 60 * 60))
                .relativeText(now: now, locale: english) == "2 hours ago")
        #expect(EventTicketTiming.live(endsAt: nil).relativeText(now: now, locale: english) == nil)
    }

    @Test func dayOffsetCountsJapanDays() {
        let start = JapanDate(year: 2026, month: 12, day: 30)

        #expect(EventTicketTiming.dayOffset(from: start, to: JapanDate(year: 2027, month: 1, day: 2)) == 3)
        #expect(EventTicketTiming.dayOffset(from: start, to: start) == 0)
    }
}
