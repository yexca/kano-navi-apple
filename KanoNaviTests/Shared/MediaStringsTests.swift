import Foundation
import Testing

@testable import KanoNavi

/// The Videos, Posts and Archive tables resolve in every interface language.
struct MediaStringsTests {
    @Test func tablesResolveInEachLanguage() {
        #expect(resolved(.Videos.newest, "en") == "Newest")
        #expect(resolved(.Videos.jumpToMonth, "ja") == "月を選ぶ")
        #expect(resolved(.Posts.agencyPost, "zh-Hans") == "事务所动态")
        #expect(resolved(.Archive.all, "ja") == "すべて")
    }

    @Test func countsArePluralized() {
        #expect(resolved(.Posts.postCount(1), "en") == "1 Post")
        #expect(resolved(.Posts.postCount(4), "ja") == "4 件")
    }

    @Test func savedNoticeNamesWhenTheCopyWasRead() {
        let time = "Tue, Nov 10 11:20 JST"
        #expect(
            resolved(.Archive.savedCopy(time), "en")
                == "Couldn’t update this month. Showing the copy from \(time).")
        #expect(resolved(.Archive.savedCopy(time), "zh-Hans").contains("截至 \(time)"))
    }

    @Test func monthChoiceShowsItsCount() {
        #expect(resolved(.Archive.monthWithCount("November 2026", 10), "en") == "November 2026 (10)")
    }

    @Test func filterChoiceShowsItsCount() {
        #expect(resolved(.Archive.filterWithCount("@example", 9), "en") == "@example (9)")
        #expect(resolved(.Archive.filterWithCount("@example", 9), "ja") == "@example（9）")
    }

    @Test func timelineNoticeNamesWhenTheCopyWasRead() {
        let time = "Tue, Nov 10 11:20 JST"
        #expect(
            resolved(.Videos.timelineSavedCopy(time), "en")
                == "Couldn’t update videos. Showing the copy from \(time).")
        #expect(resolved(.Videos.timelineSavedCopy(time), "ja").contains("\(time) 時点"))
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
