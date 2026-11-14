import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowComingUpTests {
    /// 10:00 JST on Tue, Nov 10, 2026.
    private let now = "2026-11-10T01:00:00Z"

    private func comingUp(
        _ calendar: [[String: Any]], dashboard: [[String: Any]] = [],
        shownAbove: NowComingUp.ShownAbove = NowComingUp.ShownAbove(), at instant: String? = nil
    ) throws -> NowComingUp {
        var calendarFixture = DashboardFixture()
        calendarFixture.events = calendar
        var dashboardFixture = DashboardFixture()
        dashboardFixture.events = dashboard
        return NowComingUp(
            calendarEvents: try calendarFixture.dashboard().events,
            dashboardEvents: try dashboardFixture.dashboard().events, shownAbove: shownAbove,
            now: try DashboardFixture.instant(instant ?? now))
    }

    @Test func entriesAreGroupedByJapanDayAndEmptyDaysDoNotAppear() throws {
        let result = try comingUp([
            DashboardFixture.event(id: "today", startsOn: "2026-11-10", startsAt: "2026-11-10T12:00:00Z"),
            // 01:00 JST on Nov 12 is still Nov 11 in UTC.
            DashboardFixture.event(
                id: "after-midnight", startsOn: "2026-11-12", startsAt: "2026-11-11T16:00:00Z"),
            DashboardFixture.event(id: "saturday", startsOn: "2026-11-14", startsAt: "2026-11-14T12:00:00Z"),
            DashboardFixture.event(id: "saturday-tba", startsOn: "2026-11-14"),
        ])

        #expect(result.today == JapanDate(year: 2026, month: 11, day: 10))
        #expect(result.days.map(\.date.rawValue) == ["2026-11-10", "2026-11-12", "2026-11-14"])
        #expect(
            result.days.map { $0.entries.map(\.eventID) } == [
                ["today"], ["after-midnight"], ["saturday-tba", "saturday"],
            ])
        #expect(result.recent.isEmpty)
    }

    @Test func onlyTheNextFiveEntriesAreShown() throws {
        let events = (1...7).map { day in
            DashboardFixture.event(
                id: "day-\(day)", startsOn: String(format: "2026-11-%02d", 10 + day),
                startsAt: String(format: "2026-11-%02dT12:00:00Z", 10 + day))
        }

        let result = try comingUp(events)

        #expect(
            result.days.flatMap(\.entries).map(\.eventID) == ["day-1", "day-2", "day-3", "day-4", "day-5"])
    }

    @Test func salesAreLeftOutAtTheirOpeningAndTheirClose() throws {
        let result = try comingUp([
            DashboardFixture.event(
                id: "sale", startsOn: "2026-11-11", type: "sale",
                entries: [
                    DashboardFixture.entry("2026-11-11", at: "2026-11-11T03:00:00Z", saleMark: "opens"),
                    DashboardFixture.entry("2026-11-13", at: "2026-11-13T14:59:00Z", saleMark: "closes"),
                ]),
            DashboardFixture.event(id: "stream", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z"),
        ])

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["stream"])
    }

    @Test func spotlightEventIsLeftOut() throws {
        let result = try comingUp(
            [
                DashboardFixture.event(id: "next", startsOn: "2026-11-11", startsAt: "2026-11-11T02:00:00Z"),
                DashboardFixture.event(id: "later", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z"),
            ], shownAbove: NowComingUp.ShownAbove(eventIDs: ["next"]))

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["later"])
        #expect(result.isAllShownAbove == false)
    }

    @Test func eventLinkingTheSpotlightVideoIsLeftOut() throws {
        let watch = "https://example.com/watch/V1"
        let result = try comingUp(
            [
                DashboardFixture.event(
                    id: "premiere", startsOn: "2026-11-11", startsAt: "2026-11-11T02:00:00Z",
                    links: [DashboardFixture.link("youtube", watch)]),
                DashboardFixture.event(
                    id: "announced", startsOn: "2026-11-11", startsAt: "2026-11-11T03:00:00Z", url: watch),
                DashboardFixture.event(id: "later", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z"),
            ], shownAbove: NowComingUp.ShownAbove(videoURLs: [try #require(URL(string: watch))]))

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["later"])
    }

    @Test func onlyTheSpotlightAndSalesComingUpLeaveNothingToCallEmpty() throws {
        let result = try comingUp(
            [
                DashboardFixture.event(id: "next", startsOn: "2026-11-11", startsAt: "2026-11-11T02:00:00Z"),
                DashboardFixture.event(
                    id: "sale", startsOn: "2026-11-13", type: "sale",
                    entries: [
                        DashboardFixture.entry("2026-11-13", at: "2026-11-13T14:59:00Z", saleMark: "closes")
                    ]),
            ],
            dashboard: [
                DashboardFixture.event(
                    id: "done", startsOn: "2026-11-08", startsAt: "2026-11-08T12:00:00Z", state: "done")
            ], shownAbove: NowComingUp.ShownAbove(eventIDs: ["next"]))

        #expect(result.days.isEmpty)
        #expect(result.isAllShownAbove)
        #expect(result.recent.isEmpty)
    }

    @Test func nothingComingUpIsEmptyAndListsRecentEntries() throws {
        let result = try comingUp(
            [],
            dashboard: [
                DashboardFixture.event(
                    id: "done", startsOn: "2026-11-08", startsAt: "2026-11-08T12:00:00Z", state: "done")
            ])

        #expect(result.days.isEmpty)
        #expect(result.isAllShownAbove == false)
        #expect(result.recent.map(\.eventID) == ["done"])
    }

    @Test func entriesOutsideTheTwoWeeksAreLeftOut() throws {
        let result = try comingUp([
            DashboardFixture.event(id: "yesterday", startsOn: "2026-11-09", startsAt: "2026-11-09T12:00:00Z"),
            DashboardFixture.event(id: "last-day", startsOn: "2026-11-23", startsAt: "2026-11-23T12:00:00Z"),
            DashboardFixture.event(id: "too-far", startsOn: "2026-11-24", startsAt: "2026-11-24T12:00:00Z"),
        ])

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["last-day"])
    }

    @Test func liveEntryStaysWhateverItsStart() throws {
        // Started at 23:00 JST yesterday and still live.
        let result = try comingUp([
            DashboardFixture.event(
                id: "live", startsOn: "2026-11-09", startsAt: "2026-11-09T14:00:00Z", state: "live")
        ])

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["live"])
    }

    /// Today's entries that have started stay for three hours after they
    /// end, or after they start when they have no end time.
    @Test(
        arguments: [
            ("2026-11-09T22:30:00Z", "2026-11-09T23:30:00Z", true),  // ended 1.5 hours ago
            ("2026-11-09T21:00:00Z", "2026-11-09T21:30:00Z", false),  // ended 3.5 hours ago
            ("2026-11-09T22:30:00Z", nil, true),  // started 2.5 hours ago, no end time
            ("2026-11-09T21:30:00Z", nil, false),  // started 3.5 hours ago, no end time
        ] as [(String, String?, Bool)])
    func todaysStartedEntriesStayForThreeHoursAfterTheyEnd(
        startsAt: String, endsAt: String?, isShown: Bool
    ) throws {
        let result = try comingUp([
            DashboardFixture.event(
                id: "done", startsOn: "2026-11-10", startsAt: startsAt, endsAt: endsAt, state: "done")
        ])

        #expect(result.days.isEmpty == !isShown)
    }

    @Test func dateOnlyEntryOfTodayStaysAllDay() throws {
        let result = try comingUp(
            [DashboardFixture.event(id: "all-day", startsOn: "2026-11-10")], at: "2026-11-10T14:30:00Z")

        #expect(result.days.flatMap(\.entries).map(\.eventID) == ["all-day"])
    }

    @Test func emptyRangeListsTheTwoMostRecentlyEndedEntries() throws {
        let dashboard = [
            DashboardFixture.event(
                id: "older", startsOn: "2026-11-06", startsAt: "2026-11-06T12:00:00Z", state: "done"),
            DashboardFixture.event(
                id: "latest", startsOn: "2026-11-08", startsAt: "2026-11-08T02:00:00Z",
                endsAt: "2026-11-08T06:00:00Z", state: "done"),
            DashboardFixture.event(
                id: "middle", startsOn: "2026-11-08", startsAt: "2026-11-08T03:00:00Z",
                endsAt: "2026-11-08T05:00:00Z", state: "done"),
            DashboardFixture.event(id: "no-time", startsOn: "2026-11-09", state: "done"),
            DashboardFixture.event(id: "pending", startsOn: "2026-11-09", state: "pending"),
            DashboardFixture.event(
                id: "sale", startsOn: "2026-11-09", type: "sale", state: "done",
                entries: [
                    DashboardFixture.entry("2026-11-09", at: "2026-11-09T14:00:00Z", saleMark: "closes")
                ]),
        ]

        let result = try comingUp([], dashboard: dashboard)

        #expect(result.days.isEmpty)
        #expect(result.recent.map(\.eventID) == ["latest", "middle"])
    }

    @Test func recentEntriesAreLeftOutWhenSomethingIsComingUp() throws {
        let result = try comingUp(
            [DashboardFixture.event(id: "next", startsOn: "2026-11-12", startsAt: "2026-11-12T12:00:00Z")],
            dashboard: [
                DashboardFixture.event(
                    id: "done", startsOn: "2026-11-08", startsAt: "2026-11-08T12:00:00Z", state: "done")
            ])

        #expect(result.recent.isEmpty)
    }
}
