import KanoNaviCore

/// The pure rules of the timeline: which milestones a branch filter keeps
/// and how they group into years.
nonisolated enum JourneyTimeline {
    /// The milestones of `branch` (every one for `nil`) grouped by year,
    /// oldest year first. Within a year they keep the API's page order.
    static func groups(_ milestones: [JourneyMilestone], branch: String?) -> [JourneyYearGroup] {
        let kept = milestones.filter { branch == nil || $0.branch == branch }
        let byYear = Dictionary(grouping: kept, by: \.date.year)
        return byYear.keys.sorted().map { year in
            JourneyYearGroup(year: year, milestones: byYear[year] ?? [])
        }
    }

    /// How many milestones each branch ID has.
    static func milestoneCounts(_ milestones: [JourneyMilestone]) -> [String: Int] {
        milestones.reduce(into: [:]) { counts, milestone in
            counts[milestone.branch, default: 0] += 1
        }
    }
}
