import Foundation
import Testing

@testable import KanoNavi

/// The Videos, Posts and Archive tables resolve in every interface language.
struct MediaStringsTests {
    @Test func tablesResolveInEachLanguage() {
        #expect(resolved(.Archive.newest, "en") == "Newest")
        #expect(resolved(.Archive.jumpToMonth, "ja") == "月を選ぶ")
        #expect(resolved(.Posts.agencyPost, "zh-Hans") == "事务所动态")
        #expect(resolved(.Archive.all, "ja") == "すべて")
    }

    @Test func countsArePluralized() {
        #expect(resolved(.Archive.monthPostCount(1), "en") == "1 post")
        #expect(resolved(.Archive.monthPostCount(4), "en") == "4 posts")
        #expect(resolved(.Archive.monthVideoCount(1), "en") == "1 video")
        #expect(resolved(.Archive.monthVideoCount(4), "zh-Hans") == "4 个视频")
    }

    @Test func postNoticeNamesWhenTheCopyWasRead() {
        let time = "Tue, Nov 10 11:20 JST"
        #expect(
            resolved(.Posts.timelineSavedCopy(time), "en")
                == "Couldn’t update posts. Showing the copy from \(time).")
        #expect(resolved(.Posts.timelineSavedCopy(time), "zh-Hans").contains("截至 \(time)"))
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
