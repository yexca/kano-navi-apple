import Foundation
import Testing

@testable import KanoNaviCore

struct LabelsTests {
    @Test func labelsResolveFromPackageBundle() {
        var japanese = DisplayCodeLabels.eventState(.live)
        japanese.locale = Locale(identifier: "ja")
        var chinese = DisplayCodeLabels.eventState(.live)
        chinese.locale = Locale(identifier: "zh-Hans")
        var unknown = DisplayCodeLabels.eventState(.unknown("future"))
        unknown.locale = Locale(identifier: "ja")
        #expect(String(localized: japanese) == "配信中")
        #expect(String(localized: chinese) == "直播中")
        #expect(String(localized: unknown) == "不明")
    }
}
