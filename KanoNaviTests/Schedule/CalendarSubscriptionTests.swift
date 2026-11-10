import Foundation
import Testing

@testable import KanoNavi

struct CalendarSubscriptionTests {
    private let feed = URL(string: "https://kano.example.com/api/calendar.ics")!

    @Test(arguments: [
        ("en_US", "en"),
        ("ja_JP", "ja"),
        ("zh-Hans_CN", "zh-CN"),
        ("fr_FR", "en"),
    ])
    func webcalLinkNamesTheInterfaceLanguage(locale: String, lang: String) {
        let url = CalendarSubscription.webcalURL(from: feed, interfaceLocale: Locale(identifier: locale))

        #expect(url?.absoluteString == "webcal://kano.example.com/api/calendar.ics?lang=\(lang)")
    }

    @Test func sharedLinkStaysHTTPS() {
        let url = CalendarSubscription.feedURL(from: feed, interfaceLocale: Locale(identifier: "ja_JP"))

        #expect(url?.absoluteString == "https://kano.example.com/api/calendar.ics?lang=ja")
    }

    @Test func existingLanguageIsReplaced() throws {
        let tagged = try #require(URL(string: "https://kano.example.com/api/calendar.ics?lang=ja"))

        let url = CalendarSubscription.webcalURL(from: tagged, interfaceLocale: Locale(identifier: "en_US"))

        #expect(url?.absoluteString == "webcal://kano.example.com/api/calendar.ics?lang=en")
    }
}
