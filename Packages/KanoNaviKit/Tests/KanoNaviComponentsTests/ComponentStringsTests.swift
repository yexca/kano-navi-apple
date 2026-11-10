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

    @Test func otherPlatformResolvesInJapanese() {
        #expect(resolved(ComponentStrings.otherPlatform, "ja") == "ウェブ")
    }

    @Test func timeLabelsComposeFromTheModuleCatalog() {
        #expect(resolved(ComponentStrings.timeJST("21:00"), "ja") == "21:00 JST")
        #expect(
            resolved(ComponentStrings.dateTimeJST(date: "11月12日(木)", time: "21:00"), "ja")
                == "11月12日(木) 21:00 JST")
    }

    @Test @MainActor func knownPlatformsUseTheCoreLabels() {
        #expect(resolved(PlatformMark.name(for: .youtube), "ja") == "YouTube")
        #expect(resolved(PlatformMark.name(for: .bilibili), "ja") == "bilibili")
        #expect(resolved(PlatformMark.name(for: .other), "en") == "Web")
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }
}
