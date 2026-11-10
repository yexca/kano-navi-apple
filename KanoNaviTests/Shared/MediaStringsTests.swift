import Foundation
import Testing

@testable import KanoNavi

/// The Videos, Posts and Archive tables resolve in every interface language.
struct MediaStringsTests {
    @Test func tablesResolveInEachLanguage() {
        #expect(resolved(.Videos.featured, "en") == "Featured")
        #expect(resolved(.Videos.featured, "ja") == "ピックアップ")
        #expect(resolved(.Posts.agencyPost, "zh-Hans") == "事务所动态")
        #expect(resolved(.Archive.all, "ja") == "すべて")
    }

    @Test func countsArePluralized() {
        #expect(resolved(.Videos.videoCount(1), "en") == "1 Video")
        #expect(resolved(.Videos.videoCount(4), "en") == "4 Videos")
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

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
