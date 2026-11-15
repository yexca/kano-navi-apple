import KanoNaviComponents
import KanoNaviCore
import Testing

/// Each widget entry carries its event's `view.typeCode`, so its time takes
/// the same tag color as in the app.
struct WidgetItemTagTests {
    private let schedule = WeekFixture.schedule()

    private func tag(of id: String) throws -> ScheduleTag {
        try #require(schedule.items.first { $0.id == id }).tag
    }

    @Test(arguments: [
        ("later#0", ScheduleTag.stream), ("sale#0", .sale), ("sale#1", .sale), ("members#0", .member),
        ("release#0", .release),
    ])
    func entryTakesItsEventsTag(_ id: String, _ tag: ScheduleTag) throws {
        #expect(try self.tag(of: id) == tag)
    }

    @Test func labelledStreamKeepsTheStreamTag() {
        let schedule = CalendarFixture.schedule([
            CalendarFixture.event(id: "game", day: "2026-11-10", startsAt: nil, activityCode: "game")
        ])

        #expect(schedule.items.map(\.tag) == [.stream])
    }

    @Test func unknownOrMissingTypeIsOther() {
        let schedule = CalendarFixture.schedule([
            CalendarFixture.event(id: "concert", day: "2026-11-10", startsAt: nil, typeCode: "concert")
        ])

        #expect(schedule.items.map(\.tag) == [.other])
    }

    @Test func doneAndCancelledEntriesFade() throws {
        let done = try #require(schedule.items.first { $0.id == "done#0" })
        let cancelled = try #require(schedule.items.first { $0.id == "cancelled#0" })
        let later = try #require(schedule.items.first { $0.id == "later#0" })

        #expect(ScheduleTag.isFaded(done.state))
        #expect(ScheduleTag.isFaded(cancelled.state))
        #expect(ScheduleTag.isFaded(later.state) == false)
    }
}
