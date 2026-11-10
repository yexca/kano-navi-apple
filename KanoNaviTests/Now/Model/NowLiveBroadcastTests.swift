import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowLiveBroadcastTests {
    private func fixture(spotlightShowsBroadcast: Bool) -> DashboardFixture {
        var fixture = DashboardFixture()
        fixture.events = [DashboardFixture.event(id: "E1", startsOn: "2026-11-12")]
        fixture.liveNow = [
            "platform": "bilibili", "url": "https://example.com/live", "title": "Unannounced",
            "startedAt": "2026-11-10T09:00:00Z",
        ]
        fixture.spotlight = DashboardFixture.spotlight(eventID: "E1", liveNow: spotlightShowsBroadcast)
        return fixture
    }

    @Test func broadcastGetsItsOwnCardBesideAnotherTicket() throws {
        let dashboard = try fixture(spotlightShowsBroadcast: false).dashboard()

        let broadcast = NowLiveBroadcast(dashboard: dashboard, spotlight: NowSpotlight(dashboard: dashboard))

        #expect(broadcast?.title == "Unannounced")
        #expect(broadcast?.platform == .bilibili)
    }

    @Test func broadcastIsNotRepeatedWhenTheTicketShowsIt() throws {
        let dashboard = try fixture(spotlightShowsBroadcast: true).dashboard()

        let broadcast = NowLiveBroadcast(dashboard: dashboard, spotlight: NowSpotlight(dashboard: dashboard))

        #expect(broadcast == nil)
    }
}
