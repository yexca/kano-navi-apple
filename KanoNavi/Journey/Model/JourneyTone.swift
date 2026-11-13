import SwiftUI

/// The colour of a branch's `tone` code. Colour only accompanies the
/// branch's name and portrait; it never tells branches apart alone. An
/// unknown code is `neutral`.
nonisolated enum JourneyTone: Equatable {
    case honey
    case leaf
    case berry
    case lavender
    case sky
    case neutral

    /// The opacity of the tone behind a branch tag and a selected identity
    /// card. Tone text on it stays at 4.5:1 or more in both appearances,
    /// also inside a highlighted row.
    static let tagOpacity = 0.14

    /// The opacity of the tone behind a highlighted timeline row.
    static let highlightOpacity = 0.08

    init(code: String) {
        self =
            switch code {
            case "honey": .honey
            case "leaf": .leaf
            case "berry": .berry
            case "lavender": .lavender
            case "sky": .sky
            default: .neutral
            }
    }

    /// The colour asset of a named tone; `nil` for `neutral`.
    @MainActor var colorResource: ColorResource? {
        switch self {
        case .honey: .journeyHoney
        case .leaf: .journeyLeaf
        case .berry: .journeyBerry
        case .lavender: .journeyLavender
        case .sky: .journeySky
        case .neutral: nil
        }
    }

    /// The tone for text, markers and strokes, in light and dark appearance.
    @MainActor var color: Color {
        colorResource.map { Color($0) } ?? .secondary
    }
}
