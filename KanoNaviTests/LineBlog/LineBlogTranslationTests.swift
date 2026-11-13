import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Which translation an article shows for each content language.
struct LineBlogTranslationTests {
    typealias Fixtures = LineBlogFixtures

    @Test(arguments: [
        (ContentLocale.en, true, true, ContentLocale?.some(.en)), (.en, true, false, nil),
        (.en, false, true, nil),
        (.zhHans, true, true, .zhHans), (.zhHans, true, false, nil), (.zhHans, false, true, nil),
        (.ja, true, true, nil), (.ja, false, true, nil),
    ])
    func translationShowsWhenOfferedAndNotTurnedOff(
        content: ContentLocale, isOffered: Bool, isOn: Bool, expected: ContentLocale?
    ) {
        #expect(
            LineBlogTranslationDisplay.locale(content: content, isOffered: isOffered, isOn: isOn) == expected)
    }

    @Test func translationIsOfferedForATranslatedParagraph() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("本文"), english: [[Fixtures.text("Body")]]))
        let title = LocalizedText(ja: "題名", zhCN: nil, en: nil)

        #expect(LineBlogTranslationDisplay.isOffered(content: .en, title: title, layout: layout))
        #expect(LineBlogTranslationDisplay.isOffered(content: .zhHans, title: title, layout: layout) == false)
    }

    @Test func translationIsOfferedForATranslatedTitleAlone() throws {
        let layout = try Fixtures.layout(Fixtures.paragraph(Fixtures.text("署名")))
        let title = LocalizedText(ja: "題名", zhCN: nil, en: "Title")

        #expect(LineBlogTranslationDisplay.isOffered(content: .en, title: title, layout: layout))
        #expect(
            LineBlogTranslationDisplay.isOffered(content: .zhHans, title: title, layout: layout) == false,
            "nothing in Chinese: no switch and no note")
    }

    @Test func translationIsNotOfferedWhenTheTitleOnlyRepeatsTheOriginal() throws {
        let layout = try Fixtures.layout(Fixtures.paragraph(Fixtures.text("署名")))
        let title = LocalizedText(ja: "🎈🎈", zhCN: nil, en: "🎈🎈")

        #expect(LineBlogTranslationDisplay.isOffered(content: .en, title: title, layout: layout) == false)
    }

    @Test func japaneseIsNeverOfferedATranslation() throws {
        let layout = try Fixtures.layout(
            Fixtures.paragraph(Fixtures.text("本文"), english: [[Fixtures.text("Body")]]))
        let title = LocalizedText(ja: "題名", zhCN: "标题", en: "Title")

        #expect(LineBlogTranslationDisplay.isOffered(content: .ja, title: title, layout: layout) == false)
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
        let title = LocalizedText(ja: "合成の題名", zhCN: "合成标题", en: "Synthetic Title")

        #expect(LineBlogTitle(title, translation: .en) == LineBlogTitle(title, translation: .en))
        #expect(LineBlogTitle(title, translation: .en).original == "合成の題名")
        #expect(LineBlogTitle(title, translation: .en).translated == "Synthetic Title")
        #expect(LineBlogTitle(title, translation: .zhHans).translated == "合成标题")
        #expect(LineBlogTitle(title, translation: nil).translated == nil)
    }

    @Test func translatedTitleIsLeftOutWhenMissingOrTheSame() {
        #expect(
            LineBlogTitle(LocalizedText(ja: "🎈🎈", zhCN: nil, en: "🎈🎈"), translation: .en).translated == nil)
        #expect(
            LineBlogTitle(LocalizedText(ja: "題名", zhCN: "", en: "Title"), translation: .zhHans).translated
                == nil)
    }

    @Test func readerTitleFallsBackWhenTheArchiveHasNoJapaneseTitle() {
        #expect(
            LineBlogTitle(LocalizedText(ja: nil, zhCN: "标题", en: "Title"), translation: nil).original
                == "Title")
        #expect(LineBlogTitle(LocalizedText(), translation: .en).original == nil)
    }

    @Test(arguments: [
        (ContentLocale.ja, "合成の題名"), (.en, "Synthetic Title"), (.zhHans, "合成の題名"),
    ])
    func listTitleIsInTheContentLanguageOrElseTheJapaneseOriginal(locale: ContentLocale, expected: String) {
        let title = LocalizedText(ja: "合成の題名", zhCN: nil, en: "Synthetic Title")

        #expect(LineBlogTitle.listTitle(title, locale: locale) == expected)
    }
}
