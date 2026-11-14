import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Which works the Works entry's On This Day shows for an injected today.
struct WorksOnThisDayTests {
    private static func onThisDay(
        releases: [WorksRelease] = [], participation: [WorksParticipation] = [],
        uploads: [WorksUploadCard] = [], today: JapanDate
    ) -> WorksOnThisDay {
        WorksOnThisDay(releases: releases, participation: participation, uploads: uploads, today: today)
    }

    @Test func matchesTheMonthAndDayOfPastYearsOnly() throws {
        let result = Self.onThisDay(
            releases: [
                try WorksFixtures.release(id: "past", date: "2019-11-14"),
                try WorksFixtures.release(id: "thisYear", date: "2026-11-14"),
                try WorksFixtures.release(id: "nextDay", date: "2019-11-15"),
                try WorksFixtures.release(id: "otherMonth", date: "2019-10-14"),
            ],
            today: JapanDate(year: 2026, month: 11, day: 14))

        #expect(result.entries.map(\.id) == ["release.past"])
        #expect(result.entries.map(\.yearsAgo) == [7])
    }

    @Test func listsNewestFirstAndReleasesBeforeOtherWorksOfOneDate() throws {
        let list = try WorksFixtures.uploadList([
            WorksFixtures.upload(id: "u-old", date: "2012-11-14", niconico: "sm1"),
            WorksFixtures.upload(id: "u-new", date: "2021-11-14", youtube: ["abc"]),
        ])
        let uploads = WorksUploadCard.newestFirst(list: list, stored: nil)

        let result = Self.onThisDay(
            releases: [try WorksFixtures.release(id: "r", date: "2021-11-14")],
            participation: [try WorksFixtures.participation(id: "p", date: "2015-11-14")],
            uploads: uploads, today: JapanDate(year: 2026, month: 11, day: 14))

        #expect(
            result.entries.map(\.id) == [
                "release.r", "upload.collection.u-new", "participation.p", "upload.collection.u-old",
            ])
        #expect(result.entries.map(\.yearsAgo) == [5, 5, 11, 14])
    }

    @Test func aNewerVideoMatchesByItsJapanDate() throws {
        // 15:30 UTC on November 13 is already November 14 in Japan.
        let stored = try WorksFixtures.stored(recent: [
            WorksFixtures.recent(id: "jst", publishedAt: "2025-11-13T15:30:00Z"),
            WorksFixtures.recent(id: "utc", publishedAt: "2025-11-14T15:30:00Z"),
            WorksFixtures.recent(id: "untimed"),
        ])

        let result = Self.onThisDay(
            uploads: WorksUploadCard.newestFirst(list: nil, stored: stored),
            today: JapanDate(year: 2026, month: 11, day: 14))

        #expect(result.entries.map(\.id) == ["upload.recent.jst"])
    }

    @Test func isEmptyWhenNothingMatches() throws {
        let result = Self.onThisDay(
            releases: [try WorksFixtures.release(id: "r", date: "2019-03-01")],
            today: JapanDate(year: 2026, month: 11, day: 14))

        #expect(result.entries.isEmpty)
    }

    @Test(arguments: [
        // A year without February 29 shows the leap day's works on the 28th.
        (JapanDate(year: 2026, month: 2, day: 28), ["release.leap", "release.eve"]),
        (JapanDate(year: 2026, month: 3, day: 1), []),
        // A leap year shows them on their own day alone.
        (JapanDate(year: 2028, month: 2, day: 29), ["release.leap"]),
        (JapanDate(year: 2028, month: 2, day: 28), ["release.eve"]),
        // 2100 is not a leap year.
        (JapanDate(year: 2100, month: 2, day: 28), ["release.leap", "release.eve"]),
    ])
    func leapDayWorksComeUpEveryYear(today: JapanDate, expected: [String]) throws {
        let result = Self.onThisDay(
            releases: [
                try WorksFixtures.release(id: "eve", date: "2019-02-28"),
                try WorksFixtures.release(id: "leap", date: "2020-02-29"),
            ],
            today: today)

        #expect(result.entries.map(\.id) == expected)
    }

    @Test(arguments: [(2000, true), (2024, true), (2026, false), (2100, false)])
    func leapYearsFollowTheGregorianRule(year: Int, isLeap: Bool) {
        #expect(WorksOnThisDay.isLeapYear(year) == isLeap)
    }
}
