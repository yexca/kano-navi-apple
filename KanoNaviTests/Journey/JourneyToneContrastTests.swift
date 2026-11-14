import SwiftUI
import Testing

@testable import KanoNavi

/// Tone text stays at 4.5:1 or more on the tone's own tints, in light and
/// dark appearance: plain, on a branch tag, on a highlighted row, and on a
/// tag inside a highlighted row.
@MainActor
struct JourneyToneContrastTests {
    nonisolated static let tones: [JourneyTone] = [.honey, .leaf, .berry, .lavender, .sky]

    @Test(arguments: tones, [ColorScheme.light, .dark])
    func toneTextIsReadableOnItsTints(_ tone: JourneyTone, _ scheme: ColorScheme) throws {
        let resource = try #require(tone.colorResource)
        let text = ColorComponents.rgb(Color(resource), in: scheme)
        let base = ColorComponents.rgb(ColorComponents.screenBackground, in: scheme)
        let card = blend(text, over: base, opacity: JourneyTone.highlightOpacity)
        let backgrounds = [
            base, blend(text, over: base, opacity: JourneyTone.tagOpacity), card,
            blend(text, over: card, opacity: JourneyTone.tagOpacity),
        ]
        for background in backgrounds {
            #expect(contrast(text, background) >= 4.5)
        }
    }

    @Test func unknownToneHasNoAsset() {
        #expect(JourneyTone.neutral.colorResource == nil)
    }

    private func blend(_ top: [Double], over bottom: [Double], opacity: Double) -> [Double] {
        zip(top, bottom).map { $0 * opacity + $1 * (1 - opacity) }
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
