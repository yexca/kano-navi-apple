import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct VideoShelfTests {
    @Test func joinsTheProjectionsIDsToTheSnapshotsVideosInProjectionOrder() throws {
        var fixture = DashboardFixture()
        fixture.videos = ["W2", "S1", "R1", "A1", "W1", "R2", "L1"].map { VideoFixtures.json(id: $0) }
        fixture.shelf = VideoFixtures.shelf(
            lead: "L1", featured: true, reservations: ["R2", "R1"], works: ["W1", "W2"], archives: ["A1"],
            shorts: ["S1"])

        let shelf = VideoShelf(dashboard: try fixture.dashboard())

        #expect(shelf.lead?.id == "L1")
        #expect(shelf.leadIsFeatured)
        #expect(shelf.reservations.map(\.id) == ["R2", "R1"])
        #expect(shelf.works.map(\.id) == ["W1", "W2"])
        #expect(shelf.archives.map(\.id) == ["A1"])
        #expect(shelf.shorts.map(\.id) == ["S1"])
        #expect(shelf.isEmpty == false)
    }

    @Test func leavesOutIDsWithoutAVideo() throws {
        var fixture = DashboardFixture()
        fixture.videos = [VideoFixtures.json(id: "W1")]
        fixture.shelf = VideoFixtures.shelf(lead: "gone", featured: true, works: ["missing", "W1"])

        let shelf = VideoShelf(dashboard: try fixture.dashboard())

        #expect(shelf.lead == nil)
        #expect(shelf.leadIsFeatured == false)
        #expect(shelf.works.map(\.id) == ["W1"])
    }

    @Test func derivedLeadIsNotFeatured() throws {
        var fixture = DashboardFixture()
        fixture.videos = [VideoFixtures.json(id: "L1")]
        fixture.shelf = VideoFixtures.shelf(lead: "L1", featured: false)

        let shelf = VideoShelf(dashboard: try fixture.dashboard())

        #expect(shelf.lead?.id == "L1")
        #expect(shelf.leadIsFeatured == false)
    }

    @Test func emptyShelf() throws {
        let shelf = VideoShelf(dashboard: try DashboardFixture().dashboard())

        #expect(shelf.isEmpty)
    }
}
