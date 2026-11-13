import KanoNaviCore

/// The milestones of one year on the timeline, in the order the API lists
/// them.
nonisolated struct JourneyYearGroup: Identifiable, Equatable {
    let year: Int
    let milestones: [JourneyMilestone]

    var id: Int { year }
}
