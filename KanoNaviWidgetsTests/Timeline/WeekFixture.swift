import Foundation

/// A synthetic week around ``CalendarFixture/now`` (2026-11-10 10:00 JST):
/// a finished stream, a live one, one later today, a sale that opened two
/// days ago and closes on the 12th, a cancelled and a members stream
/// tomorrow, and a date-only release on the 13th.
enum WeekFixture {
    static let records: [[String: Any]] = [
        CalendarFixture.event(
            id: "later", day: "2026-11-10", startsAt: "2026-11-10T12:00:00Z"),
        CalendarFixture.event(
            id: "sale", day: "2026-11-09", startsAt: "2026-11-09T03:00:00Z", state: "open",
            typeCode: "sale",
            entries: [
                .init(day: "2026-11-09", startsAt: "2026-11-09T03:00:00Z", saleMark: "opens"),
                .init(day: "2026-11-12", startsAt: "2026-11-12T09:00:00Z", saleMark: "closes"),
            ]),
        CalendarFixture.event(
            id: "live", day: "2026-11-10", startsAt: "2026-11-10T00:00:00Z",
            endsAt: "2026-11-10T02:00:00Z", state: "live"),
        CalendarFixture.event(
            id: "done", day: "2026-11-10", startsAt: "2026-11-09T23:00:00Z", state: "done"),
        CalendarFixture.event(
            id: "members", day: "2026-11-11", startsAt: "2026-11-11T13:00:00Z", typeCode: "member"),
        CalendarFixture.event(
            id: "cancelled", day: "2026-11-11", startsAt: "2026-11-11T11:00:00Z", state: "cancelled"),
        CalendarFixture.event(id: "release", day: "2026-11-13", startsAt: nil, typeCode: "release"),
    ]

    static func schedule(nextTransitionAt: Date? = nil) -> WidgetSchedule {
        CalendarFixture.schedule(records, nextTransitionAt: nextTransitionAt)
    }
}
