import Foundation
import Testing

struct UpcomingTimelineBuilderTests {
    private let now = CalendarFixture.now

    @Test func createsAnEntryNowAndAtEachTransition() {
        let schedule = WeekFixture.schedule()
        let timeline = UpcomingTimelineBuilder.timeline(for: .schedule(schedule), now: now)
        #expect(timeline.entries.map(\.date) == [now] + schedule.transitionDates(after: now))
        #expect(timeline.entries.allSatisfy { $0.content == .schedule(schedule) })
    }

    @Test func capsTheNumberOfEntries() {
        let records = (0..<80).map { index in
            CalendarFixture.event(
                id: "stream-\(index)", day: "2026-11-10",
                startsAt: now.addingTimeInterval(Double(index + 1) * 60).ISO8601Format())
        }
        let timeline = UpcomingTimelineBuilder.timeline(
            for: .schedule(CalendarFixture.schedule(records)), now: now)
        #expect(timeline.entries.count == UpcomingTimelineBuilder.maximumEntries)
    }

    /// Minutes from now to the service's next transition, and to the reload.
    @Test(arguments: zip([10, 45, -5], [10, 30, 30]))
    func reloadsAtTheNextTransitionOrWithinHalfAnHour(transitionMinutes: Int, reloadMinutes: Int) {
        let next = now.addingTimeInterval(TimeInterval(transitionMinutes * 60))
        let schedule = WeekFixture.schedule(nextTransitionAt: next)
        let timeline = UpcomingTimelineBuilder.timeline(for: .schedule(schedule), now: now)
        #expect(timeline.reloadDate == now.addingTimeInterval(TimeInterval(reloadMinutes * 60)))
    }

    @Test func reloadsWithinHalfAnHourWithoutAKnownTransition() {
        let timeline = UpcomingTimelineBuilder.timeline(for: .schedule(WeekFixture.schedule()), now: now)
        #expect(timeline.reloadDate == now.addingTimeInterval(30 * 60))
    }

    @Test func retriesSoonerWhenNothingCouldBeRead() {
        let timeline = UpcomingTimelineBuilder.timeline(for: .unavailable, now: now)
        #expect(timeline.entries == [UpcomingEntry(date: now, content: .unavailable)])
        #expect(timeline.reloadDate == now.addingTimeInterval(15 * 60))
    }
}
