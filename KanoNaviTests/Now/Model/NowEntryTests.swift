import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowEntryTests {
    @Test func entriesAreInJapanDateOrderThenDateOnlyFirstThenTimeWithTiesInAPIOrder() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(id: "next-day", startsOn: "2026-11-11", startsAt: "2026-11-10T16:00:00Z"),
            DashboardFixture.event(id: "evening", startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z"),
            DashboardFixture.event(id: "morning-a", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z"),
            DashboardFixture.event(id: "all-day", startsOn: "2026-11-10"),
            DashboardFixture.event(id: "morning-b", startsOn: "2026-11-10", startsAt: "2026-11-10T01:00:00Z"),
        ]

        let entries = NowEntry.entries(in: try fixture.dashboard().events)

        #expect(entries.map(\.eventID) == ["all-day", "morning-a", "morning-b", "evening", "next-day"])
    }

    @Test func saleHasAnEntryAtItsOpeningAndAtItsClose() throws {
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

        let entries = NowEntry.entries(in: try fixture.dashboard().events)

        #expect(entries.map(\.id) == ["sale#0", "sale#1"])
        #expect(entries.map(\.calendarEntry.saleMark) == [.opens, .closes])
        #expect(entries.map(\.state) == [.open, .open])
    }

    @Test func endOfTheEventsOwnEntryIsItsEndElseItsStart() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "stream", startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z",
                endsAt: "2026-11-10T13:00:00Z"),
            DashboardFixture.event(
                id: "open-ended", startsOn: "2026-11-10", startsAt: "2026-11-10T11:00:00Z"),
            DashboardFixture.event(id: "date-only", startsOn: "2026-11-10"),
        ]

        let entries = NowEntry.entries(in: try fixture.dashboard().events)
        let ends = Dictionary(uniqueKeysWithValues: entries.map { ($0.eventID, $0.endedAt) })

        #expect(ends["stream"] == (try DashboardFixture.instant("2026-11-10T13:00:00Z")))
        #expect(ends["open-ended"] == (try DashboardFixture.instant("2026-11-10T11:00:00Z")))
        #expect(ends["date-only"] == .some(nil))
    }
}
