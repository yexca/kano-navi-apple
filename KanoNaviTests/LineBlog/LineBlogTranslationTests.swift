import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Which translation an article shows for each content language.
struct LineBlogTranslationTests {
    typealias Fixtures = LineBlogFixtures

    @Test(arguments: [
        (ContentLocale.ja, true, ContentLocale?.none), (.ja, false, nil), (.en, true, .en), (.en, false, nil),
        (.zhHans, true, .zhHans), (.zhHans, false, nil),
    ])
    func translationFollowsTheContentLanguageUnlessJapaneseOrTurnedOff(
        content: ContentLocale, isOn: Bool, expected: ContentLocale?
    ) {
        #expect(LineBlogTranslationDisplay.locale(content: content, isOn: isOn) == expected)
    }

    @Test func paragraphShowsTheTranslationOfTheChosenLanguageOnly() throws {
        let article = try Fixtures.article(
            Fixtures.paragraph(
                Fixtures.text("こんにちは"), chinese: [[Fixtures.text("你好")]], english: [[Fixtures.text("Hello")]])
        )
        let layout = LineBlogArticleLayout(article: article)
        guard case .paragraph(let paragraph)? = layout.blocks.first?.content else {
            Issue.record("expected a paragraph")
            return
        }

        #expect(paragraph.translation(in: .en).map(\.plainText) == ["Hello"])
        #expect(paragraph.translation(in: .zhHans).map(\.plainText) == ["你好"])
        #expect(paragraph.translation(in: .ja).isEmpty, "Japanese is the original")
        #expect(paragraph.translation(in: nil).isEmpty)
    }

    @Test func paragraphWithoutATranslationInTheLanguageShowsNone() throws {
        let article = try Fixtures.article(
            Fixtures.paragraph(Fixtures.text("署名"), english: [[Fixtures.text("Signature")]]),
            ["type": "paragraph", "content": [Fixtures.text("本文")], "translations": NSNull()])
        let paragraphs = LineBlogArticleLayout(article: article).blocks.compactMap { block in
            if case .paragraph(let paragraph) = block.content { paragraph } else { nil }
        }

        #expect(paragraphs.map { $0.translation(in: .zhHans).count } == [0, 0])
        #expect(paragraphs.map { $0.translation(in: .en).count } == [1, 0])
    }

    // MARK: Titles

    @Test func readerTitleIsTheJapaneseOriginalWithTheTranslationUnderIt() {
        let title = LocalizedText(ja: "春の服", zhCN: "春天的衣服", en: "Spring Clothes")

        #expect(LineBlogTitle(title, translation: .en) == LineBlogTitle(title, translation: .en))
        #expect(LineBlogTitle(title, translation: .en).original == "春の服")
        #expect(LineBlogTitle(title, translation: .en).translated == "Spring Clothes")
        #expect(LineBlogTitle(title, translation: .zhHans).translated == "春天的衣服")
        #expect(LineBlogTitle(title, translation: nil).translated == nil)
    }

    @Test func translatedTitleIsLeftOutWhenMissingOrTheSame() {
        #expect(
            LineBlogTitle(LocalizedText(ja: "🌊🐄", zhCN: nil, en: "🌊🐄"), translation: .en).translated == nil)
        #expect(
            LineBlogTitle(LocalizedText(ja: "春", zhCN: "", en: "Spring"), translation: .zhHans).translated
                == nil)
    }

    @Test func readerTitleFallsBackWhenTheArchiveHasNoJapaneseTitle() {
        #expect(
            LineBlogTitle(LocalizedText(ja: nil, zhCN: "标题", en: "Title"), translation: nil).original
                == "Title")
        #expect(LineBlogTitle(LocalizedText(), translation: .en).original == nil)
    }

    @Test(arguments: [
        (ContentLocale.ja, "春の服"), (.en, "Spring Clothes"), (.zhHans, "春の服"),
    ])
    func listTitleIsInTheContentLanguageOrElseTheJapaneseOriginal(locale: ContentLocale, expected: String) {
        let title = LocalizedText(ja: "春の服", zhCN: nil, en: "Spring Clothes")

        #expect(LineBlogTitle.listTitle(title, locale: locale) == expected)
    }
}
