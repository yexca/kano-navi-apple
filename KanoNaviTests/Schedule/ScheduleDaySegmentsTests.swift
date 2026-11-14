import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

/// A day's capsule has a segment per tag, in order, at most three, faded
/// only when every entry of the tag is over.
struct ScheduleDaySegmentsTests {
    private let november = JapanDate(year: 2026, month: 11, day: 1)
    private let day = JapanDate(year: 2026, month: 11, day: 10)

    private func marks(_ specs: [(typeCode: String, state: String)]) throws -> [ScheduleDayMark] {
        let events = try specs.enumerated().map { index, spec in
            try ScheduleFixtures.event(
                id: "e\(index)", startsOn: "2026-11-10",
                startsAt: "2026-11-10T0\(index):00:00Z", state: spec.state, typeCode: spec.typeCode)
        }
        let days = ScheduleMonthDays(month: november, events: events)
        return days.entries(on: day).map { ScheduleDayMark($0) }
    }

    @Test func oneSegmentPerTagInOrderOfFirstEntry() throws {
        let segments = ScheduleDaySegments.segments(
            of: try marks([
                ("stream", "upcoming"), ("sale", "open"), ("stream", "upcoming"), ("release", "upcoming"),
            ]))

        #expect(segments.map(\.tag) == [.stream, .sale, .release])
    }

    @Test func capsuleStopsAtThreeTags() throws {
        let segments = ScheduleDaySegments.segments(
            of: try marks([
                ("stream", "upcoming"), ("member", "upcoming"), ("event", "upcoming"), ("video", "upcoming"),
            ]))

        #expect(segments.count == ScheduleDaySegments.limit)
        #expect(segments.map(\.tag) == [.stream, .member, .event])
    }

    @Test func segmentFadesOnlyWhenAllItsEntriesAreOver() throws {
        let segments = ScheduleDaySegments.segments(
            of: try marks([("stream", "done"), ("stream", "upcoming"), ("sale", "cancelled")]))

        #expect(segments == [.init(tag: .stream, isFaded: false), .init(tag: .sale, isFaded: true)])
    }

    @Test func dayWithoutEntriesHasNoSegments() {
        #expect(ScheduleDaySegments.segments(of: []).isEmpty)
    }
}
