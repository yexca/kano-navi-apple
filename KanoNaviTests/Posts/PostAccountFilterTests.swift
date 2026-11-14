import Foundation
import KanoNaviComponents
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct PostAccountFilterTests {
    @Test func listsTheXAccountsThenBilibiliWithLowercaseCounts() throws {
        var fixture = DashboardFixture()
        fixture.xAccounts = ["Kano_Example", "@_Sub"]
        fixture.bilibiliAccounts = ["316381099"]
        let meta = try fixture.dashboard().meta
        let counts = ["kano_example": 2, "_sub": 1, "316381099": 1, "agency": 1]

        let accounts = PostAccountFilter.accounts(meta: meta, counts: counts)
        let options = PostAccountFilter.options(accounts: accounts, counts: counts, allCount: 5)

        // The API's `account` takes a handle without `@`.
        #expect(options.map(\.code) == [nil, "Kano_Example", "_Sub", "316381099"])
        #expect(options.map(\.count) == [5, 2, 1, 1])
        #expect(options[1].label == .verbatim("@Kano_Example"))
        #expect(options.map(\.logo) == [nil, .x, .x, .bilibili])
    }

    @Test func withoutASnapshotTheFilterOffersTheCountedAccounts() {
        let accounts = PostAccountFilter.accounts(meta: nil, counts: ["b": 1, "a": 2])

        #expect(accounts.map(\.code) == ["a", "b"])
    }

    @Test func countsAreUnknownBeforeTheTimelineLoads() {
        let options = PostAccountFilter.options(
            accounts: [PostFilterAccount(code: "a", isBilibili: false)], counts: [:], allCount: nil)

        #expect(options.allSatisfy { $0.count == nil })
    }
}
