import KanoNaviComponents
import KanoNaviCore
import SwiftUI
import Testing

@testable import KanoNavi

/// Entries take their color from `view.typeCode`, or `eventType` when an
/// activity label stands in for the type code, and their text stays
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

    @Test func labelledStreamKeepsTheStreamTag() throws {
        let event = try ScheduleFixtures.event(id: "game", startsOn: "2026-11-10", activityCode: "game")

        #expect(event.view?.typeCode == nil)
        #expect(ScheduleTag(event: event) == .stream)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func streamsUseTheAppsBerry(_ scheme: ColorScheme) {
        let berry = ColorComponents.rgb(Color(.journeyBerry), in: scheme)

        #expect(rounded(rgb(of: .stream, scheme)) == rounded(berry))
    }

    @Test(arguments: [EventState.done, .cancelled])
    func overOrCalledOffEntriesFade(_ state: EventState) {
        #expect(ScheduleTag.isFaded(state))
    }

    @Test(arguments: [EventState.upcoming, .live, .open, .pending, .cancellationReview])
    func currentEntriesKeepTheirColor(_ state: EventState) {
        #expect(ScheduleTag.isFaded(state) == false)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func everyTagHasItsOwnColor(_ scheme: ColorScheme) {
        let colors = ScheduleTag.allCases.map { rounded(rgb(of: $0, scheme)) }
        #expect(Set(colors).count == ScheduleTag.allCases.count)
    }

    @Test(arguments: ScheduleTag.allCases, [ColorScheme.light, .dark])
    func tagTextIsReadableOnItsTint(_ tag: ScheduleTag, _ scheme: ColorScheme) {
        let text = rgb(of: tag, scheme)
        let base = ColorComponents.rgb(ColorComponents.screenBackground, in: scheme)
        let tint = zip(text, base).map { $0 * ScheduleTag.tintOpacity + $1 * (1 - ScheduleTag.tintOpacity) }

        #expect(contrast(text, tint) >= 4.5)
    }

    /// The widgets' light cream and pink, and dark plum backgrounds.
    @Test(
        arguments: ScheduleTag.allCases,
        [
            (ColorScheme.light, ["FDF9F6", "FBEAEE"]), (.dark, ["16121C", "241A2C"]),
        ])
    func tagTextIsReadableOnTheWidgetBackgrounds(
        _ tag: ScheduleTag, _ appearance: (ColorScheme, [String])
    ) {
        let text = rgb(of: tag, appearance.0)
        for hex in appearance.1 {
            #expect(contrast(text, srgb(hex)) >= 4.5, "\(tag) on #\(hex)")
        }
    }

    private func rgb(of tag: ScheduleTag, _ scheme: ColorScheme) -> [Double] {
        ColorComponents.rgb(tag.color, in: scheme)
    }

    private func rounded(_ color: [Double]) -> [Double] {
        color.map { ($0 * 255).rounded() }
    }

    private func srgb(_ hex: String) -> [Double] {
        let value = Int(hex, radix: 16) ?? 0
        return [16, 8, 0].map { Double((value >> $0) & 0xFF) / 255 }
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
