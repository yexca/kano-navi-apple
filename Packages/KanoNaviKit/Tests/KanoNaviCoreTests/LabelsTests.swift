import Foundation
import Testing

@testable import KanoNaviCore

struct LabelsTests {
    private static let locales = ["en", "ja", "zh-Hans"]

    /// The compiled catalog of one localization, read straight from the
    /// package bundle so a missing value cannot fall back to English.
    private func compiledStrings(_ localization: String) throws -> [String: String] {
        let url = try #require(
            KanoNaviResources.bundle.url(
                forResource: "Localizable", withExtension: "strings", subdirectory: nil,
                localization: localization))
        return try #require(NSDictionary(contentsOf: url) as? [String: String])
    }

    private func resolved(_ resource: LocalizedStringResource, _ identifier: String) -> String {
        var resource = resource
        resource.locale = Locale(identifier: identifier)
        return String(localized: resource)
    }

    @Test func labelsResolveFromPackageBundle() {
        #expect(resolved(DisplayCodeLabels.eventState(.live), "ja") == "配信中")
        #expect(resolved(DisplayCodeLabels.eventState(.live), "zh-Hans") == "直播中")
        #expect(resolved(DisplayCodeLabels.eventState(.unknown("future")), "ja") == "不明")
    }

    @Test(arguments: locales)
    func everyLabelKeyHasAValue(_ localization: String) throws {
        let strings = try compiledStrings(localization)
        #expect(DisplayCodeLabels.allKeys.contains("platform.other"))
        for key in DisplayCodeLabels.allKeys {
            let value = strings[key]
            #expect(value?.isEmpty == false, "\(key) has no \(localization) value")
            #expect(value != key, "\(key) resolves to its key in \(localization)")
        }
    }

    @Test func catalogHoldsOnlyLabelKeys() throws {
        let catalogKeys = Set(try compiledStrings("en").keys)
        #expect(catalogKeys == Set(DisplayCodeLabels.allKeys))
    }

    @Test(arguments: locales)
    func labelsResolveToTextRatherThanKeys(_ identifier: String) {
        let labels: [LocalizedStringResource] = [
            DisplayCodeLabels.eventState(.unknown("future")),
            DisplayCodeLabels.eventType(nil),
            DisplayCodeLabels.tag("future"),
            DisplayCodeLabels.platform(.other),
            DisplayCodeLabels.platform(.unknown("future")),
            DisplayCodeLabels.form(nil),
            DisplayCodeLabels.syncStatus("success"),
        ]
        for label in labels {
            #expect(resolved(label, identifier) != label.key)
        }
    }

    @Test func platformNamesFollowTheBoard() {
        #expect(resolved(DisplayCodeLabels.platform(.other), "en") == "Web")
        #expect(resolved(DisplayCodeLabels.platform(.other), "ja") == "Web")
        #expect(resolved(DisplayCodeLabels.platform(.other), "zh-Hans") == "网页")
        #expect(resolved(DisplayCodeLabels.platform(.bilibili), "ja") == "bilibili")
        #expect(resolved(DisplayCodeLabels.platform(.bilibili), "zh-Hans") == "哔哩哔哩")
    }

    @Test func chineseStreamLabelsAreChinese() {
        #expect(resolved(DisplayCodeLabels.eventType("stream"), "zh-Hans") == "直播")
        #expect(resolved(DisplayCodeLabels.tag("live"), "zh-Hans") == "直播")
    }
}
