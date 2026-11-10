import Foundation
import Testing

@testable import KanoNavi

struct ScheduleStringsTests {
    @Test func scheduleTableResolvesInEachLanguage() {
        #expect(resolved(.Schedule.today, "en") == "Today")
        #expect(resolved(.Schedule.today, "ja") == "今日")
        #expect(resolved(.Schedule.today, "zh-Hans") == "今天")
    }

    @Test func entryCountIsPluralized() {
        #expect(resolved(.Schedule.dayEntryCount(1), "en") == "1 entry")
        #expect(resolved(.Schedule.dayEntryCount(3), "en") == "3 entries")
        #expect(resolved(.Schedule.dayEntryCount(3), "ja") == "3件の予定")
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
