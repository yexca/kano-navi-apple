import KanoNaviComponents

/// The colored segments of a day's capsule in the List mode's month, as in
/// Calendar: one per tag among the day's entries, in the order the tags
/// first appear, at most ``limit``. A segment fades only when every entry of
/// its tag is done or cancelled.
nonisolated enum ScheduleDaySegments {
    /// The most segments a capsule draws.
    static let limit = 3

    struct Segment: Equatable, Sendable {
        let tag: ScheduleTag
        let isFaded: Bool
    }

    static func segments(of marks: [ScheduleDayMark]) -> [Segment] {
        var order: [ScheduleTag] = []
        var faded: [ScheduleTag: Bool] = [:]
        for mark in marks {
            if faded[mark.tag] == nil {
                order.append(mark.tag)
                faded[mark.tag] = mark.isFaded
            } else if mark.isFaded == false {
                faded[mark.tag] = false
            }
        }
        return order.prefix(limit).map { Segment(tag: $0, isFaded: faded[$0] ?? false) }
    }
}
