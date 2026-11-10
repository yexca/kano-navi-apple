import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowEntryTests {
    @Test func entriesFollowJapanDatesNotTheDeviceDate() throws {
        var fixture = DashboardFixture()
        // 15:30 UTC on Nov 10 is 00:30 on Nov 11 in Japan.
        fixture.events = [
            DashboardFixture.event(id: "late", startsOn: "2026-11-11", startsAt: "2026-11-10T15:30:00Z"),
            DashboardFixture.event(id: "next", startsOn: "2026-11-12", startsAt: "2026-11-12T03:00:00Z"),
        ]
        let now = try DashboardFixture.instant("2026-11-10T16:00:00Z")

        let board = NowBoard(dashboard: try fixture.dashboard(), now: now)

        #expect(board.today == JapanDate(year: 2026, month: 11, day: 11))
        #expect(board.todayEntries.map(\.eventID) == ["late"])
        #expect(board.tomorrowEntries.map(\.eventID) == ["next"])
    }

    @Test func dateOnlyEntriesComeFirstThenTimeOrderWithTiesInAPIOrder() throws {
        let events = [
            DashboardFixture.event(id: "evening", startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z"),
            DashboardFixture.event(id: "morning-a", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z"),
            DashboardFixture.event(id: "all-day", startsOn: "2026-11-10"),
            DashboardFixture.event(id: "morning-b", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z"),
        ]
        var fixture = DashboardFixture()
        fixture.events = events

        let entries = NowEntry.entries(
            on: JapanDate(year: 2026, month: 11, day: 10), in: try fixture.dashboard().events)

        #expect(entries.map(\.eventID) == ["all-day", "morning-a", "morning-b", "evening"])
    }

    @Test func saleShowsItsClosingEntryOnTheClosingDay() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "sale", startsOn: "2026-11-08", type: "sale", state: "open",
                entries: [
                    DashboardFixture.entry("2026-11-08", at: "2026-11-08T03:00:00Z", saleMark: "opens"),
                    DashboardFixture.entry("2026-11-10", at: "2026-11-10T14:59:00Z", saleMark: "closes"),
                ]
            )
        ]

        let entries = NowEntry.entries(
            on: JapanDate(year: 2026, month: 11, day: 10), in: try fixture.dashboard().events)

        let entry = try #require(entries.first)
        #expect(entries.count == 1)
        #expect(entry.saleMark == .closes)
        #expect(entry.state == .open)
        #expect(entry.id == "sale#1")
    }

    @Test func membersEntriesAreMarked() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(id: "members", startsOn: "2026-11-10", type: "member"),
            DashboardFixture.event(id: "public", startsOn: "2026-11-10", type: "stream"),
        ]

        let entries = NowEntry.entries(
            on: JapanDate(year: 2026, month: 11, day: 10), in: try fixture.dashboard().events)

        #expect(entries.map(\.isMembers) == [true, false])
    }
}
