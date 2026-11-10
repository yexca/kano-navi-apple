import Foundation
import KanoNaviCore
import Testing

struct WidgetDeepLinkTests {
    /// Parses an event link the way the app's router does.
    private func routedEventID(_ url: URL) -> String? {
        guard url.scheme == "kanonavi", url.host() == "event" else { return nil }
        return url.pathComponents.dropFirst().joined(separator: "/")
    }

    @Test func eventLinkNamesTheEvent() {
        #expect(WidgetDeepLink.event("youtube-SYNTH01").absoluteString == "kanonavi://event/youtube-SYNTH01")
    }

    @Test(arguments: ["synthetic-calendar-+00-18", "two words", "slash/inside", "per%cent", "日本語"])
    func eventIDsSurviveTheRoundTrip(id: String) {
        #expect(routedEventID(WidgetDeepLink.event(id)) == id)
    }

    @Test func scheduleLinkNamesTheJapanDate() {
        #expect(
            WidgetDeepLink.schedule(CalendarFixture.today).absoluteString
                == "kanonavi://schedule?date=2026-11-10")
    }

    @Test func entryOpensTheScheduleOnItsJapanDate() {
        let lateEvening = UpcomingEntry(
            date: CalendarFixture.date("2026-11-10T16:00:00Z"), content: .unavailable)
        #expect(lateEvening.scheduleURL.absoluteString == "kanonavi://schedule?date=2026-11-11")
    }

    @Test func itemOpensItsEvent() throws {
        let item = try #require(WeekFixture.schedule().items.first { $0.id == "sale#1" })
        #expect(item.url.absoluteString == "kanonavi://event/sale")
    }
}
