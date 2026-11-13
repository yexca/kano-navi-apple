import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// An identity reads as itself with or without a portrait.
struct JourneyBranchMarkTests {
    @Test func branchWithoutPortraitDrawsASymbolAndKeepsItsName() throws {
        let branch = try JourneyFixtures.decode(
            JourneyBranch.self, JourneyFixtures.branch("beta", tone: "sky"))
        #expect(branch.portrait == nil)
        #expect(JourneyBranchMark(branch: branch) == .symbol(JourneyBranchMark.missingPortraitSymbol))
        #expect(branch.label.resolved(for: .ja)?.text == "Branch beta")
        #expect(branch.since == "2010")
        #expect(JourneyTone(code: branch.tone) == .sky)
    }

    @Test func branchWithPortraitDrawsIt() throws {
        var object = JourneyFixtures.branch("alpha")
        object["portrait"] = JourneyFixtures.media("portrait")
        let branch = try JourneyFixtures.decode(JourneyBranch.self, object)
        #expect(JourneyBranchMark(branch: branch) == .portrait(try #require(branch.portrait)))
    }

    @Test func allCardHasItsOwnSymbol() {
        #expect(JourneyBranchMark(branch: nil) == .symbol(JourneyBranchMark.allSymbol))
        #expect(JourneyBranchMark.allSymbol != JourneyBranchMark.missingPortraitSymbol)
    }
}
