import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowSaleTests {
    @Test func salesFollowTheProjectionOrderAndSkipMissingRecords() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(id: "first", startsOn: "2026-11-09", type: "sale"),
            DashboardFixture.event(id: "second", startsOn: "2026-11-12", type: "sale"),
        ]
        fixture.sales = ["second", "missing", "first"]

        let sales = NowSale.sales(in: try fixture.dashboard())

        #expect(sales.map(\.id) == ["second", "first"])
    }

    @Test func saleWindowComesFromItsCalendarEntries() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "sale", startsOn: "2026-11-09", type: "sale", state: "open",
                entries: [
                    DashboardFixture.entry("2026-11-09", at: "2026-11-09T03:00:00Z", saleMark: "opens"),
                    DashboardFixture.entry("2026-11-12", saleMark: "closes"),
                ]
            )
        ]
        fixture.sales = ["sale"]

        let sale = try #require(NowSale.sales(in: try fixture.dashboard()).first)

        #expect(sale.state == .open)
        #expect(sale.opens?.date == JapanDate(year: 2026, month: 11, day: 9))
        #expect(sale.opens?.time == (try DashboardFixture.instant("2026-11-09T03:00:00Z")))
        #expect(sale.closes == NowSale.Moment(date: JapanDate(year: 2026, month: 11, day: 12), time: nil))
    }

    @Test func saleWithoutCalendarEntriesUsesItsStoredWindow() throws {
        var fixture = DashboardFixture()
        fixture.events = [
            DashboardFixture.event(
                id: "sale", startsOn: "2026-11-09", type: "sale", entries: [],
                saleWindow: ["startsOn": "2026-11-09", "endsOn": "2026-11-20"]
            )
        ]
        fixture.sales = ["sale"]

        let sale = try #require(NowSale.sales(in: try fixture.dashboard()).first)

        #expect(sale.opens?.date == JapanDate(year: 2026, month: 11, day: 9))
        #expect(sale.closes?.date == JapanDate(year: 2026, month: 11, day: 20))
    }
}
