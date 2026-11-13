import Foundation
import Testing

@testable import KanoNaviCore

struct LocalizedTextTests {
    @Test func decodesNullAndMissingMembers() throws {
        let text = try ArchiveFixtures.decode(LocalizedText.self, from: #"{"ja":"日本語","zh-CN":null}"#)
        #expect(text == LocalizedText(ja: "日本語"))
        #expect(text.text(in: .ja) == "日本語")
        #expect(text.text(in: .zhHans) == nil)
        #expect(text.text(in: .en) == nil)
    }

    @Test func requestedLanguageWinsWhenPresent() throws {
        let text = LocalizedText(ja: "日本語", zhCN: "中文", en: "English")
        let resolved = try #require(text.resolved(for: .zhHans))
        #expect(resolved == LocalizedTextResolution(text: "中文", locale: .zhHans, requestedLocale: .zhHans))
        #expect(resolved.isFallback == false)
    }

    @Test(arguments: [
        (LocalizedText(ja: "日本語", zhCN: nil, en: "English"), ContentLocale.en),
        (LocalizedText(ja: "日本語", zhCN: nil, en: nil), ContentLocale.ja),
        (LocalizedText(ja: nil, zhCN: nil, en: "English"), ContentLocale.en),
    ])
    func defaultFallbackIsEnglishThenJapanese(text: LocalizedText, expected: ContentLocale) throws {
        let resolved = try #require(text.resolved(for: .zhHans))
        #expect(resolved.locale == expected)
        #expect(resolved.requestedLocale == .zhHans)
        #expect(resolved.isFallback)
    }

    @Test func japaneseOriginalFallbackPrefersJapanese() throws {
        let text = LocalizedText(ja: "日本語", zhCN: nil, en: "English")
        let resolved = try #require(
            text.resolved(for: .zhHans, fallback: LocalizedText.japaneseOriginalFallback))
        #expect(resolved.text == "日本語")
        #expect(resolved.locale == .ja)
    }

    @Test func chineseIsTheLastDefaultFallback() throws {
        let text = LocalizedText(ja: nil, zhCN: "中文", en: nil)
        let resolved = try #require(text.resolved(for: .en))
        #expect(resolved.locale == .zhHans)
    }

    @Test func emptyStringCountsAsMissing() throws {
        let text = try ArchiveFixtures.decode(
            LocalizedText.self, from: #"{"ja":"日本語","zh-CN":"","en":""}"#)
        #expect(text.text(in: .zhHans) == nil)
        let resolved = try #require(text.resolved(for: .zhHans))
        #expect(resolved.locale == .ja)
    }

    @Test func everyLanguageMissingResolvesToNil() throws {
        let text = try ArchiveFixtures.decode(
            LocalizedText.self, from: #"{"ja":null,"zh-CN":"","en":null}"#)
        #expect(text.isEmpty)
        #expect(text.resolved(for: .ja) == nil)
    }

    @Test func contentLanguagePreferenceFollowsTheInterfaceLocale() throws {
        let text = LocalizedText(ja: "日本語", zhCN: "中文", en: "English")
        let resolved = try #require(text.resolved(for: .system, interfaceLocale: Locale(identifier: "ja_JP")))
        #expect(resolved.text == "日本語")
    }
}
