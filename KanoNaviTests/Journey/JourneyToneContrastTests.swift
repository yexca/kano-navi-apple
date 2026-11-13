import SwiftUI
import Testing
import UIKit

@testable import KanoNavi

/// Tone text stays at 4.5:1 or more on the tone's own tints, in light and
/// dark appearance: plain, on a branch tag, on a highlighted row, and on a
/// tag inside a highlighted row.
@MainActor
struct JourneyToneContrastTests {
    nonisolated static let tones: [JourneyTone] = [.honey, .leaf, .berry, .lavender, .sky]

    @Test(arguments: tones, [UIUserInterfaceStyle.light, .dark])
    func toneTextIsReadableOnItsTints(_ tone: JourneyTone, _ style: UIUserInterfaceStyle) throws {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let resource = try #require(tone.colorResource)
        let text = rgb(UIColor(resource: resource).resolvedColor(with: traits))
        let base = rgb(UIColor.systemBackground.resolvedColor(with: traits))
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

    private func rgb(_ color: UIColor) -> [Double] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue].map(Double.init)
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
