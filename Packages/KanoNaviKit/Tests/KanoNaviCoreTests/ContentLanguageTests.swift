import Foundation
import Testing

@testable import KanoNaviCore

struct ContentLanguageTests {
  private let translations = Translations(
    en: Translation(text: "English", origin: .manual),
    ja: Translation(text: "日本語", origin: .platform),
    zhCN: Translation(text: "中文", origin: .machine)
  )

  @Test(arguments: [
    (ContentLanguage.system, "en", "English"),
    (.system, "ja", "日本語"),
    (.system, "zh-CN", "中文"),
  ])
  func systemUsesInterfaceLocale(
    _ input: (ContentLanguage, String, String)
  ) {
    let result = ContentLanguageResolver.resolve(
      original: "Original",
      sourceLanguage: "en",
      translations: translations,
      preference: input.0,
      interfaceLocale: Locale(identifier: input.1)
    )
    #expect(result.text == input.2)
    #expect(result.isTranslation)
    #expect(result.original == "Original")
  }

  @Test func missingAndEmptyTranslationsFallBackToOriginal() {
    let missing = ContentLanguageResolver.resolve(
      original: "Original",
      sourceLanguage: "en",
      translations: Translations(ja: nil),
      preference: .ja
    )
    let empty = ContentLanguageResolver.resolve(
      original: "Original",
      sourceLanguage: "en",
      translations: Translations(ja: Translation(text: "", origin: .machine)),
      preference: .ja
    )
    #expect(missing.text == "Original")
    #expect(missing.isTranslation == false)
    #expect(empty.text == "Original")
    #expect(empty.isTranslation == false)
  }

  @Test(arguments: [TranslationOrigin.manual, .platform, .machine, .unknown("new")])
  func japaneseSourceAlwaysKeepsOriginal(_ origin: TranslationOrigin) {
    let result = ContentLanguageResolver.resolve(
      original: "日本語原文",
      sourceLanguage: "ja",
      translations: Translations(
        ja: Translation(text: "Translated", origin: origin)
      ),
      preference: .system,
      interfaceLocale: Locale(identifier: "ja")
    )
    #expect(result.text == "日本語原文")
    #expect(result.isTranslation == false)
    #expect(result.origin == nil)
  }
}
