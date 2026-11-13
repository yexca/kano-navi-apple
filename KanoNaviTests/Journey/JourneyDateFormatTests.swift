import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Milestone dates keep their stored precision in every interface language.
struct JourneyDateFormatTests {
    struct Case: Sendable, CustomTestStringConvertible {
        let locale: String
        let year: String
        let month: String
        let day: String
        let range: String
        let fullMonth: String
        let fullDay: String
        let fullRange: String

        var testDescription: String { locale }
    }

    static let cases = [
        Case(
            locale: "en", year: "2016", month: "Sep", day: "Sep 7", range: "Jun 25 – Sep 30",
            fullMonth: "September 2016", fullDay: "September 7, 2016", fullRange: "Jun 25 – Sep 30, 2024"),
        Case(
            locale: "ja", year: "2016年", month: "9月", day: "9月7日", range: "6月25日～9月30日",
            fullMonth: "2016年9月", fullDay: "2016年9月7日", fullRange: "2024年6月25日～9月30日"),
        Case(
            locale: "zh-Hans", year: "2016年", month: "9月", day: "9月7日", range: "6月25日至9月30日",
            fullMonth: "2016年9月", fullDay: "2016年9月7日", fullRange: "2024年6月25日 – 9月30日"),
    ]

    @Test(arguments: cases)
    func shortDateKeepsPrecision(_ expected: Case) throws {
        let locale = Locale(identifier: expected.locale)
        #expect(short(try date("2016"), locale: locale) == expected.year)
        #expect(short(try date("2016-09"), locale: locale) == expected.month)
        #expect(short(try date("2016-09-07"), locale: locale) == expected.day)
        #expect(short(try date("2024-06-25"), end: "2024-09-30", locale: locale) == expected.range)
    }

    @Test(arguments: cases)
    func fullDateNamesTheYear(_ expected: Case) throws {
        let locale = Locale(identifier: expected.locale)
        #expect(full(try date("2016"), locale: locale) == expected.year)
        #expect(full(try date("2016-09"), locale: locale) == expected.fullMonth)
        #expect(full(try date("2016-09-07"), locale: locale) == expected.fullDay)
        #expect(full(try date("2024-06-25"), end: "2024-09-30", locale: locale) == expected.fullRange)
    }

    @Test func shortRangeAcrossYearsNamesBothYears() throws {
        let text = short(try date("2024-12-25"), end: "2025-01-03", locale: Locale(identifier: "en"))
        #expect(text == "Dec 25, 2024 – Jan 3, 2025")
    }

    @Test func endOnOrBeforeTheStartIsLeftOut() throws {
        let locale = Locale(identifier: "en")
        #expect(short(try date("2024-06-25"), end: "2024-06-25", locale: locale) == "Jun 25")
        #expect(full(try date("2024-06-25"), end: "2024-06-01", locale: locale) == "June 25, 2024")
    }

    @Test(arguments: [("en", "Sep – Oct 3, 2016"), ("ja", "9月～2016年10月3日"), ("zh-Hans", "9月至2016年10月3日")])
    func monthWithEndJoinsTheEndDay(_ identifier: String, _ expected: String) throws {
        #expect(
            short(try date("2016-09"), end: "2016-10-03", locale: Locale(identifier: identifier)) == expected)
    }

    @Test func mediaDayIsAJapanDate() throws {
        let day = JourneyDateFormat.day(
            try #require(JapanDate(rawValue: "2016-09-07")), locale: Locale(identifier: "en"))
        #expect(normalized(day) == "Sep 7, 2016")
    }

    private func date(_ raw: String) throws -> JourneyDate {
        try #require(JourneyDate(rawValue: raw))
    }

    private func short(_ date: JourneyDate, end: String? = nil, locale: Locale) -> String {
        normalized(JourneyDateFormat.short(date, end: end.flatMap(JapanDate.init(rawValue:)), locale: locale))
    }

    private func full(_ date: JourneyDate, end: String? = nil, locale: Locale) -> String {
        normalized(JourneyDateFormat.full(date, end: end.flatMap(JapanDate.init(rawValue:)), locale: locale))
    }

    /// ICU puts thin and narrow no-break spaces around range dashes.
    private func normalized(_ text: String) -> String {
        text.replacing("\u{2009}", with: " ").replacing("\u{202F}", with: " ")
    }
}
