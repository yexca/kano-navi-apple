import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowTimeFormatTests {
    private let locale = Locale(identifier: "en_GB")

    @Test func timesAreShownInJapanWhateverTheDeviceTimeZone() throws {
        let instant = try DashboardFixture.instant("2026-11-10T12:00:00Z")

        #expect(NowTimeFormat.time(instant, locale: locale) == "21:00")
    }

    @Test func dayNamesTheJapanWeekday() {
        let day = NowTimeFormat.day(JapanDate(year: 2026, month: 11, day: 10), locale: locale)

        #expect(day.contains("Tue"))
        #expect(day.contains("10"))
    }

    @Test(arguments: [(60.0, true), (23 * 3600.0, true), (25 * 3600.0, false)])
    func countdownUsesATimerWithinADay(seconds: TimeInterval, usesTimer: Bool) {
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        #expect(NowTimeFormat.usesTimer(until: now.addingTimeInterval(seconds), now: now) == usesTimer)
    }
}
