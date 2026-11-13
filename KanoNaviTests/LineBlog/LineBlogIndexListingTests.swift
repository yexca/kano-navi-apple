import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// The article list is grouped by Japan month and year.
struct LineBlogIndexListingTests {
    typealias Fixtures = LineBlogFixtures

    @Test func articlesAreGroupedByTheirMonthInJapanTime() throws {
        let listing = LineBlogIndexListing(posts: [
            // 00:30 on March 1 in Japan, still February 28 in UTC.
            try Fixtures.summary(id: "3", published: "2019-02-28T15:30:00.000Z"),
            // 23:59 on February 28 in Japan.
            try Fixtures.summary(id: "2", published: "2019-02-28T14:59:00.000Z"),
            try Fixtures.summary(id: "1", published: "2019-02-01T00:00:00.000Z"),
        ])

        #expect(listing.months.map(\.key.rawValue) == ["2019-03", "2019-02"])
        #expect(listing.months.map { $0.posts.map(\.id) } == [["3"], ["2", "1"]])
    }

    @Test func monthsAndArticlesKeepTheServiceOrder() throws {
        let listing = LineBlogIndexListing(posts: [
            try Fixtures.summary(id: "5", published: "2018-01-13T03:00:00.000Z"),
            try Fixtures.summary(id: "4", published: "2017-11-18T03:00:00.000Z"),
            try Fixtures.summary(id: "3", published: "2017-11-01T03:00:00.000Z"),
            try Fixtures.summary(id: "2", published: "2017-09-29T03:00:00.000Z"),
            try Fixtures.summary(id: "1", published: "2015-10-08T03:00:00.000Z"),
        ])

        #expect(listing.months.map(\.id) == ["2018-01", "2017-11", "2017-09", "2015-10"])
        #expect(listing.years.map(\.year) == [2018, 2017, 2015])
        #expect(listing.years.map(\.total) == [1, 3, 1])
        #expect(listing.years[1].months.map(\.id) == ["2017-11", "2017-09"])
    }

    @Test func aYearTurnsAtMidnightInJapan() throws {
        let listing = LineBlogIndexListing(posts: [
            try Fixtures.summary(id: "2", published: "2016-12-31T15:00:00.000Z"),
            try Fixtures.summary(id: "1", published: "2016-12-31T14:59:59.000Z"),
        ])

        #expect(listing.years.map(\.year) == [2017, 2016])
    }

    @Test func aMonthListedTwiceIsOneGroup() throws {
        let listing = LineBlogIndexListing(posts: [
            try Fixtures.summary(id: "3", published: "2017-05-20T03:00:00.000Z"),
            try Fixtures.summary(id: "2", published: "2017-04-10T03:00:00.000Z"),
            try Fixtures.summary(id: "1", published: "2017-05-02T03:00:00.000Z"),
        ])

        #expect(listing.months.map(\.id) == ["2017-05", "2017-04"])
        #expect(listing.months[0].posts.map(\.id) == ["3", "1"])
    }

    @Test func anEmptyArchiveHasNoMonths() {
        let listing = LineBlogIndexListing(posts: [])

        #expect(listing.months.isEmpty)
        #expect(listing.years.isEmpty)
    }
}
