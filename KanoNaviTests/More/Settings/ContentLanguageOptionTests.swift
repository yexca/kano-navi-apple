import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct ContentLanguageOptionTests {
    @Test func pickerOffersEveryLanguageWithSameAsAppFirst() {
        #expect(ContentLanguageOption.all == [.system, .en, .ja, .zhHans])
        #expect(Set(ContentLanguageOption.all) == Set(ContentLanguage.allCases))
    }

    @Test(
        arguments: [
            (ContentLanguage.system, nil),
            (.en, "English"),
            (.ja, "日本語"),
            (.zhHans, "简体中文"),
        ] as [(ContentLanguage, String?)])
    func languagesAreNamedInTheirOwnLanguage(language: ContentLanguage, autonym: String?) {
        #expect(ContentLanguageOption.autonym(of: language) == autonym)
    }
}
