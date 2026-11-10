import KanoNaviCore
import Testing

struct WidgetContentLanguageTests {
    @Test(arguments: [
        (WidgetContentLanguage.sameAsApp, ContentLanguage.system),
        (.english, .en),
        (.japanese, .ja),
        (.simplifiedChinese, .zhHans),
    ])
    func mapsToTheCoreContentLanguage(choice: WidgetContentLanguage, expected: ContentLanguage) {
        #expect(choice.contentLanguage == expected)
    }

    @Test func defaultsToTheAppLanguage() {
        #expect(UpcomingConfigurationIntent().language == .sameAsApp)
    }
}
