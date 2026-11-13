import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The gallery lists every image once, in timeline order, and filters by
/// branch and category.
struct JourneyGalleryTests {
    let gallery: JourneyGallery

    init() throws {
        let shared = JourneyFixtures.media(
            "shared", branches: ["alpha", "beta"], category: "cover", origin: "release")
        let journey = try JourneyFixtures.journey(
            milestones: [
                JourneyFixtures.milestone(
                    "m1", date: "2015-05-20",
                    media: [JourneyFixtures.media("a1"), shared]),
                JourneyFixtures.milestone(
                    "m2", date: "2016-01-01", branch: "beta",
                    media: [JourneyFixtures.media("b1", branches: ["beta"], category: "frame"), shared]),
            ],
            galleryOnly: [
                JourneyFixtures.media("g1", branches: ["beta"], category: "model"),
                JourneyFixtures.media("n1", category: "sticker"),
            ])
        gallery = JourneyGallery(journey)
    }

    @Test func listsMilestoneImagesInTimelineOrderThenGalleryOnly() {
        #expect(gallery.items.map(\.id) == ["a1", "shared", "b1", "g1", "n1"])
    }

    @Test func imageOfSeveralBranchesAppearsOnceInEachBranch() {
        #expect(gallery.items.count { $0.id == "shared" } == 1)
        #expect(gallery.items(branch: "alpha", category: nil).map(\.id) == ["a1", "shared", "n1"])
        #expect(gallery.items(branch: "beta", category: nil).map(\.id) == ["shared", "b1", "g1"])
        #expect(gallery.branchCounts == ["alpha": 3, "beta": 3])
    }

    @Test func categoryFilterCombinesWithBranch() {
        #expect(gallery.items(branch: nil, category: "cover").map(\.id) == ["shared"])
        #expect(gallery.items(branch: "alpha", category: "frame").isEmpty)
        #expect(gallery.items(branch: "beta", category: "frame").map(\.id) == ["b1"])
    }

    @Test func categoriesComeInFixedOrderThenNewCodes() {
        let all = gallery.categories(branch: nil)
        #expect(all.map(\.id) == ["artwork", "model", "frame", "cover", "sticker"])
        #expect(all.map(\.count) == [1, 1, 1, 1, 1])
        #expect(gallery.categories(branch: "beta").map(\.id) == ["model", "frame", "cover"])
    }
}
