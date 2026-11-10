import Foundation
import Testing

@testable import KanoNavi

@MainActor
struct NowTimeFormatTests {
    @Test(arguments: [(60.0, true), (23 * 3600.0, true), (25 * 3600.0, false)])
    func countdownUsesATimerWithinADay(seconds: TimeInterval, usesTimer: Bool) {
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        #expect(NowTimeFormat.usesTimer(until: now.addingTimeInterval(seconds), now: now) == usesTimer)
    }
}
