import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import Testing
import UIKit

@testable import KanoNavi

/// Entries take their color from `view.typeCode`, and their text stays
/// readable on the Details tint and on the widgets' backgrounds in both
/// appearances.
@MainActor
struct ScheduleTagTests {
    @Test(arguments: [
        ("stream", ScheduleTag.stream), ("member", .member), ("event", .event), ("release", .release),
        ("video", .video), ("sale", .sale),
    ])
    func typeCodeNamesItsTag(_ code: String, _ tag: ScheduleTag) {
        #expect(ScheduleTag(typeCode: code) == tag)
    }

    @Test(arguments: [nil, "", "concert", "Stream"] as [String?])
    func missingOrUnknownCodeIsOther(_ code: String?) {
        #expect(ScheduleTag(typeCode: code) == .other)
    }

    @Test func eventWithoutAViewIsOther() throws {
        let event = try ScheduleFixtures.event(id: "x", startsOn: "2026-11-10", typeCode: "sale")
        var bare = event
        bare.view = nil

        #expect(ScheduleTag(event: event) == .sale)
        #expect(ScheduleTag(event: bare) == .other)
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func streamsUseTheAppsBerry(_ style: UIUserInterfaceStyle) {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let berry = components(UIColor(resource: .journeyBerry).resolvedColor(with: traits))

        #expect(rounded(rgb(of: .stream, style)) == rounded(berry))
    }

    @Test(arguments: [EventState.done, .cancelled])
    func overOrCalledOffEntriesFade(_ state: EventState) {
        #expect(ScheduleTag.isFaded(state))
    }

    @Test(arguments: [EventState.upcoming, .live, .open, .pending, .cancellationReview])
    func currentEntriesKeepTheirColor(_ state: EventState) {
        #expect(ScheduleTag.isFaded(state) == false)
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func everyTagHasItsOwnColor(_ style: UIUserInterfaceStyle) {
        let colors = ScheduleTag.allCases.map { rounded(rgb(of: $0, style)) }
        #expect(Set(colors).count == ScheduleTag.allCases.count)
    }

    @Test(arguments: ScheduleTag.allCases, [UIUserInterfaceStyle.light, .dark])
    func tagTextIsReadableOnItsTint(_ tag: ScheduleTag, _ style: UIUserInterfaceStyle) {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let text = rgb(of: tag, style)
        let base = components(UIColor.systemBackground.resolvedColor(with: traits))
        let tint = zip(text, base).map { $0 * ScheduleTag.tintOpacity + $1 * (1 - ScheduleTag.tintOpacity) }

        #expect(contrast(text, tint) >= 4.5)
    }

    /// The widgets' light cream and pink, and dark plum backgrounds.
    @Test(
        arguments: ScheduleTag.allCases,
        [
            (UIUserInterfaceStyle.light, ["FDF9F6", "FBEAEE"]), (.dark, ["16121C", "241A2C"]),
        ])
    func tagTextIsReadableOnTheWidgetBackgrounds(
        _ tag: ScheduleTag, _ appearance: (UIUserInterfaceStyle, [String])
    ) {
        let text = rgb(of: tag, appearance.0)
        for hex in appearance.1 {
            #expect(contrast(text, srgb(hex)) >= 4.5, "\(tag) on #\(hex)")
        }
    }

    private func rgb(of tag: ScheduleTag, _ style: UIUserInterfaceStyle) -> [Double] {
        let traits = UITraitCollection(userInterfaceStyle: style)
        return components(UIColor(tag.color).resolvedColor(with: traits))
    }

    private func rounded(_ color: [Double]) -> [Double] {
        color.map { ($0 * 255).rounded() }
    }

    private func srgb(_ hex: String) -> [Double] {
        let value = Int(hex, radix: 16) ?? 0
        return [16, 8, 0].map { Double((value >> $0) & 0xFF) / 255 }
    }

    private func components(_ color: UIColor) -> [Double] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue].map(Double.init)
    }

    /// The WCAG contrast ratio of two sRGB colours.
    private func contrast(_ first: [Double], _ second: [Double]) -> Double {
        let values = [luminance(first), luminance(second)].sorted(by: >)
        return (values[0] + 0.05) / (values[1] + 0.05)
    }

    private func luminance(_ color: [Double]) -> Double {
        let linear = color.map { $0 <= 0.039_28 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
        return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
    }
}
