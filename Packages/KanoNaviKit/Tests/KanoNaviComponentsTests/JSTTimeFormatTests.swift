import Foundation
import KanoNaviCore
import Testing

@testable import KanoNaviComponents

struct JSTTimeFormatTests {
    /// 2026-11-12 21:00 in Japan.
    private let instant = Date(timeIntervalSince1970: 1_794_484_800)
    private let english = Locale(identifier: "en_GB")
    private let japanese = Locale(identifier: "ja_JP")

    @Test(arguments: [
        ("exact", true),
        ("date", false),
        ("unknown", false),
        ("approximate", true),
    ])
    func timeShowsOnlyForTimedEntries(precision: String, showsTime: Bool) {
        #expect(JSTTimeFormat.showsTime(startsAt: instant, timePrecision: precision) == showsTime)
    }

    @Test func entryWithoutAStartShowsNoTime() {
        #expect(JSTTimeFormat.showsTime(startsAt: nil, timePrecision: "exact") == false)
    }

    @Test func timeIsInJapanWhateverTheDeviceZone() {
        #expect(JSTTimeFormat.time(instant, locale: english) == "21:00 JST")
        #expect(JSTTimeFormat.time(instant, locale: japanese) == "21:00 JST")
    }

    @Test func dateAndTimeNameTheJapanDay() {
        // 2026-11-12 21:00 JST is still 2026-11-12 in Japan but 12:00 UTC.
        #expect(JSTTimeFormat.dateTime(instant, locale: english) == "Thu 12 Nov 21:00 JST")
    }

    @Test func dayFollowsTheInterfaceLanguage() {
        let day = JapanDate(year: 2026, month: 11, day: 12)

        #expect(JSTTimeFormat.day(day, locale: japanese) == "11月12日(木)")
    }

    @Test func dateOnlyEntryShowsItsDateOrNothing() {
        let day = JapanDate(year: 2026, month: 11, day: 12)

        let withoutDate = JSTTimeFormat.entry(
            startsAt: nil, startsOn: day, timePrecision: "date", includesDate: false, locale: english)
        let withDate = JSTTimeFormat.entry(
            startsAt: nil, startsOn: day, timePrecision: "date", includesDate: true, locale: english)

        #expect(withoutDate == nil)
        #expect(withDate == "Thu 12 Nov")
    }

    @Test func timedEntryShowsItsTime() {
        let text = JSTTimeFormat.entry(
            startsAt: instant, startsOn: JapanDate(year: 2026, month: 11, day: 12), timePrecision: "exact",
            includesDate: false, locale: english)

        #expect(text == "21:00 JST")
    }
}
