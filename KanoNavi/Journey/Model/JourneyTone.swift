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

    /// The tone for text, markers and strokes, in light and dark appearance.
    @MainActor var color: Color {
        switch self {
        case .honey: Color(.journeyHoney)
        case .leaf: Color(.journeyLeaf)
        case .berry: Color(.journeyBerry)
        case .lavender: Color(.journeyLavender)
        case .sky: Color(.journeySky)
        case .neutral: .secondary
        }
    }
}
