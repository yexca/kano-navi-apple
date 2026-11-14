import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Milestones group by year, oldest first, and filter by branch.
struct JourneyTimelineTests {
    let journey: JourneyResponse

    init() throws {
        journey = try JourneyFixtures.journey(milestones: [
            JourneyFixtures.milestone("a", date: "2010"),
            JourneyFixtures.milestone("b", date: "2015-05-20"),
            JourneyFixtures.milestone("c", date: "2015-03", branch: "beta"),
            JourneyFixtures.milestone("d", date: "2021-05-29", branch: "beta"),
            JourneyFixtures.milestone("e", date: "2015-11-18"),
        ])
    }

    @Test func groupsByYearOldestFirstKeepingPageOrderWithinAYear() {
        let groups = JourneyTimeline.groups(journey.milestones, branch: nil)
        #expect(groups.map(\.year) == [2010, 2015, 2021])
        #expect(groups[1].milestones.map(\.id) == ["b", "c", "e"])
    }

    @Test func branchFilterKeepsOnlyItsMilestones() {
        let groups = JourneyTimeline.groups(journey.milestones, branch: "beta")
        #expect(groups.map(\.year) == [2015, 2021])
        #expect(groups.flatMap(\.milestones).map(\.id) == ["c", "d"])
    }

    @Test func unknownBranchLeavesNothing() {
        #expect(JourneyTimeline.groups(journey.milestones, branch: "gamma").isEmpty)
    }

    @Test func topYearIsTheFirstGroupWithAMilestoneOnScreenWhateverTheReportedOrder() {
        let groups = JourneyTimeline.groups(journey.milestones, branch: nil)
        let slot = { (year: Int, id: String) in JourneyTimelineSlot(year: year, milestoneID: id) }

        #expect(JourneyTimeline.topYear(of: groups, visible: [slot(2021, "d"), slot(2015, "e")]) == 2015)
        #expect(JourneyTimeline.topYear(of: groups, visible: [slot(2010, "a")]) == 2010)
        #expect(JourneyTimeline.topYear(of: groups, visible: [slot(1999, "x")]) == nil)
        #expect(JourneyTimeline.topYear(of: groups, visible: []) == nil)
    }

    @Test func countsMilestonesPerBranch() {
        #expect(JourneyTimeline.milestoneCounts(journey.milestones) == ["alpha": 3, "beta": 2])
    }
}
