/// The scroll target of a year's header on the timeline. It is its own type
/// so that it never matches the year groups' `ForEach` identity, which is
/// the bare year.
nonisolated struct JourneyYearAnchor: Hashable {
    let year: Int
}
