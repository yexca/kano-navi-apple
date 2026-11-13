import Foundation
import Testing

@testable import KanoNavi

/// The Media and Document tables resolve in every interface language.
struct SharedStringsTests {
    @Test func tablesResolveInEachLanguage() {
        #expect(resolved(.Media.imageUnavailable, "en") == "Image unavailable")
        #expect(resolved(.Media.imageUnavailable, "ja") == "画像を表示できません")
        #expect(resolved(.Media.viewerClose, "zh-Hans") == "关闭")
        #expect(resolved(.Document.retry, "ja") == "再試行")
        #expect(resolved(.Document.reasonServerError(503), "en") == "The service responded with error 503.")
    }

    @Test func viewerCounterNamesThePositionAndTheCount() {
        #expect(resolved(.Media.viewerPosition(3, 12), "en") == "3 / 12")
        #expect(resolved(.Media.viewerPositionSpoken(3, 12), "en") == "Image 3 of 12")
        #expect(resolved(.Media.viewerPositionSpoken(3, 12), "ja") == "12 枚中 3 枚目")
        #expect(resolved(.Media.viewerPositionSpoken(3, 12), "zh-Hans") == "第 3 张，共 12 张")
    }

    @Test func savedNoticeNamesWhenTheCopyWasRead() {
        let time = "Tue, Nov 10 11:20 JST"
        #expect(
            resolved(.Document.savedCopy(time), "en")
                == "Couldn’t update this page. Showing the copy from \(time).")
        #expect(resolved(.Document.savedCopy(time), "ja").contains("\(time) 時点"))
        #expect(resolved(.Document.savedCopy(time), "zh-Hans").contains("截至 \(time)"))
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
