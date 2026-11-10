import Foundation
import KanoNaviCore
import Testing

@testable import KanoNaviComponents

struct ComponentStringsTests {
    @Test func liveWordResolvesInEachInterfaceLanguage() {
        #expect(resolved(ComponentStrings.live, "en") == "Live")
        #expect(resolved(ComponentStrings.live, "ja") == "配信中")
        #expect(resolved(ComponentStrings.live, "zh-Hans") == "直播中")
    }

    @Test func timeLabelsComposeFromTheModuleCatalog() {
        #expect(resolved(ComponentStrings.timeJST("21:00"), "ja") == "21:00 JST")
        #expect(
            resolved(ComponentStrings.dateTimeJST(date: "11月12日(木)", time: "21:00"), "ja")
                == "11月12日(木) 21:00 JST")
    }

    @Test func ticketWordsResolveInEachInterfaceLanguage() {
        #expect(resolved(ComponentStrings.timeTBA, "ja") == "時間未定")
        #expect(resolved(ComponentStrings.approximateTime("21:00"), "en") == "About 21:00")
        #expect(resolved(ComponentStrings.approximateTime("21:00"), "zh-Hans") == "约 21:00")
        #expect(resolved(ComponentStrings.liveUntil("23:00"), "ja") == "23:00 まで")
        #expect(resolved(ComponentStrings.liveSince("21:00"), "en") == "Since 21:00")
        #expect(resolved(ComponentStrings.joined("配信", "ゲーム"), "ja") == "配信・ゲーム")
        #expect(resolved(ComponentStrings.timeZoneJST, "zh-Hans") == "JST")
    }

    @Test @MainActor func knownPlatformsUseTheCoreLabels() {
        #expect(resolved(PlatformMark.name(for: .youtube), "ja") == "YouTube")
        #expect(resolved(PlatformMark.name(for: .bilibili), "ja") == "bilibili")
    }

    @Test(arguments: ["en", "ja", "zh-Hans"])
    @MainActor func otherPlatformUsesTheCoreLabel(_ identifier: String) {
        #expect(
            resolved(PlatformMark.name(for: .other), identifier)
                == resolved(DisplayCodeLabels.platform(.other), identifier))
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
