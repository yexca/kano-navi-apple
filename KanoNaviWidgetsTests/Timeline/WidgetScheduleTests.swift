import Foundation
import KanoNaviCore
import Testing

struct WidgetScheduleTests {
    private let schedule = WeekFixture.schedule()
    private let now = CalendarFixture.now

    @Test func ordersEntriesByJapanDayThenTime() {
        #expect(
            schedule.items.map(\.id) == [
                "sale#0", "done#0", "live#0", "later#0", "cancelled#0", "members#0", "sale#1", "release#0",
            ])
    }

    @Test func listsDateOnlyEntriesFirstInTheirDay() {
        let records = [
            CalendarFixture.event(id: "timed", day: "2026-11-13", startsAt: "2026-11-12T16:00:00Z"),
            CalendarFixture.event(id: "allDay", day: "2026-11-13", startsAt: nil),
        ]
        #expect(CalendarFixture.schedule(records).items.map(\.eventID) == ["allDay", "timed"])
    }

    @Test func currentEntriesStartWithLiveThenWhatIsAhead() {
        #expect(
            schedule.current(at: now).map(\.id) == [
                "live#0", "later#0", "cancelled#0", "members#0", "sale#1", "release#0",
            ])
    }

    @Test func liveEntryStopsBeingLiveAtItsEnd() throws {
        let live = try #require(schedule.items.first { $0.eventID == "live" })
        #expect(live.isLive(at: now))
        #expect(live.isLive(at: CalendarFixture.date("2026-11-10T02:00:00Z")) == false)
        #expect(schedule.next(at: CalendarFixture.date("2026-11-10T02:00:00Z"))?.id == "later#0")
    }

    @Test func nextSkipsCancelledEntries() {
        let afterTonight = CalendarFixture.date("2026-11-11T10:00:00Z")
        #expect(schedule.current(at: afterTonight).first?.id == "cancelled#0")
        #expect(schedule.next(at: afterTonight)?.id == "members#0")
    }

    @Test func saleClosingIsItsOwnEntryWithoutAnEnd() throws {
        let closing = try #require(schedule.items.first { $0.id == "sale#1" })
        #expect(closing.saleMark == .closes)
        #expect(closing.day == JapanDate(year: 2026, month: 11, day: 12))
        #expect(closing.endsAt == nil)
    }

    @Test func dateOnlyEntryStaysCurrentForItsWholeJapanDay() throws {
        let release = try #require(schedule.items.first { $0.eventID == "release" })
        #expect(release.isPast(at: CalendarFixture.date("2026-11-13T14:59:00Z")) == false)
        #expect(release.isPast(at: CalendarFixture.date("2026-11-13T15:00:00Z")))
    }

    @Test(arguments: [
        (ContentLanguage.en, "Morning chat"),
        (.ja, "朝の雑談"),
        (.zhHans, "早间杂谈"),
        (.system, "Morning chat"),
    ])
    func resolvesTitlesForTheContentLanguage(language: ContentLanguage, title: String) {
        let record = CalendarFixture.event(
            id: "talk", day: "2026-11-10", startsAt: "2026-11-10T03:00:00Z", title: "朝の雑談",
            sourceLanguage: "ja", translations: ["en": "Morning chat", "zh-CN": "早间杂谈"])
        #expect(CalendarFixture.schedule([record], language: language).items.first?.title == title)
    }

    @Test func groupsUpcomingDaysWithinTheLineBudget() {
        let days = schedule.upcomingDays(at: now, lineBudget: 5)
        #expect(days.map(\.date.rawValue) == ["2026-11-10", "2026-11-11"])
        #expect(days.map { $0.items.map(\.eventID) } == [["live", "later"], ["cancelled"]])
    }

    @Test func doesNotStartADayHeadingWithoutRoomForAnEntry() {
        let days = schedule.upcomingDays(at: now, lineBudget: 4)
        #expect(days.map { $0.items.map(\.eventID) } == [["live", "later"]])
    }

    @Test func listsALiveEntryFromAnEarlierDayUnderToday() {
        let records = [
            CalendarFixture.event(
                id: "overnight", day: "2026-11-09", startsAt: "2026-11-09T14:00:00Z",
                endsAt: "2026-11-10T02:00:00Z", state: "live")
        ]
        let days = CalendarFixture.schedule(records).upcomingDays(at: now, lineBudget: 5)
        #expect(days.map(\.date) == [CalendarFixture.today])
    }

    @Test func weekShowsSevenDaysFromToday() {
        let week = schedule.week(at: now, lineBudget: 9)
        #expect(week.map(\.date) == (0..<7).map { CalendarFixture.today.addingDays($0) })
        #expect(
            week.map { $0.items.map(\.eventID) } == [
                ["live", "later"], ["cancelled", "members"], ["sale"], ["release"], [], [], [],
            ])
        #expect(week.map(\.hiddenCount) == [0, 0, 0, 0, 0, 0, 0])
    }

    @Test func weekCountsEntriesThatDoNotFit() {
        let week = schedule.week(at: now, lineBudget: 8)
        #expect(week[1].items.map(\.eventID) == ["cancelled"])
        #expect(week[1].hiddenCount == 1)
    }

    @Test func countsTwoLinesPerEntryWhenTimesSitAboveTitles() {
        let days = schedule.upcomingDays(at: now, lineBudget: 8, itemLines: 2)
        #expect(days.map { $0.items.map(\.eventID) } == [["live", "later"], ["cancelled"]])
    }

    @Test func transitionsIncludeStartsEndsSaleClosingAndDayBoundaries() {
        #expect(
            schedule.transitionDates(after: now)
                == [
                    "2026-11-10T02:00:00Z",  // live ends
                    "2026-11-10T12:00:00Z",  // later starts
                    "2026-11-11T11:00:00Z",  // cancelled
                    "2026-11-11T13:00:00Z",  // members starts
                    "2026-11-12T09:00:00Z",  // sale closes
                    "2026-11-12T15:00:00Z",  // release day begins in Japan
                    "2026-11-13T15:00:00Z",  // release day ends in Japan
                ].map(CalendarFixture.date))
    }
}
