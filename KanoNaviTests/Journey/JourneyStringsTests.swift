import Foundation
import Testing

@testable import KanoNavi

/// The Journey table is complete in every interface language.
struct JourneyStringsTests {
    @Test(arguments: ["ja", "zh-Hans"])
    func everyEnglishKeyIsTranslated(_ language: String) throws {
        let english = try keys("en")
        #expect(english.count > 90)
        #expect(english.subtracting(try keys(language)).isEmpty)
    }

    @Test func codesAreWordedInEachLanguage() {
        #expect(resolved(.Journey.kindDebut, "ja") == "デビュー")
        #expect(resolved(.Journey.kindDebut, "zh-Hans") == "出道")
        #expect(resolved(.Journey.categoryCover, "ja") == "ジャケット")
        #expect(resolved(.Journey.linkX, "zh-Hans") == "X 原帖")
        #expect(resolved(.Journey.dateKindStream, "en") == "Original stream date")
    }

    @Test func missingMilestoneHasItsOwnWording() {
        #expect(resolved(.Journey.milestoneMissingTitle, "en") == "Milestone Not Found")
        #expect(resolved(.Journey.milestoneMissingTitle, "ja") == "出来事が見つかりません")
        #expect(resolved(.Journey.milestoneMissingTitle, "zh-Hans") == "找不到此节点")
        #expect(resolved(.Journey.milestoneMissingMessage, "en") != resolved(.Journey.timelineEmpty, "en"))
    }

    @Test func countsArePluralized() {
        #expect(resolved(.Journey.milestoneCount(1), "en") == "1 milestone")
        #expect(resolved(.Journey.milestoneCount(28), "en") == "28 milestones")
        #expect(resolved(.Journey.imageCount(73), "ja") == "73 枚")
        #expect(resolved(.Journey.imageCount(73), "zh-Hans") == "73 张图片")
    }

    /// The keys of the compiled table for one language, plain and plural.
    private func keys(_ language: String) throws -> Set<String> {
        let folder = try #require(Bundle.main.url(forResource: language, withExtension: "lproj"))
        var keys = Set<String>()
        for kind in ["strings", "stringsdict"] {
            let url = folder.appending(path: "Journey.\(kind)")
            guard let table = NSDictionary(contentsOf: url) as? [String: Any] else { continue }
            keys.formUnion(table.keys)
        }
        return keys
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
