import Foundation

/// A milestone's `kind` code (an open set) with its wording and symbol. An
/// unknown code reads as a neutral "Milestone".
nonisolated enum JourneyKind: Equatable {
    case start
    case debut
    case release
    case character
    case outfit
    case model3d
    case stream
    case group
    case live
    case collab
    case agency
    case artwork
    case goods
    case other

    /// Every kind the catalog words, `other` last.
    static let allCases: [JourneyKind] = [
        .start, .debut, .release, .character, .outfit, .model3d, .stream, .group, .live, .collab,
        .agency, .artwork, .goods, .other,
    ]

    init(code: String) {
        self =
            switch code {
            case "start": .start
            case "debut": .debut
            case "release": .release
            case "character": .character
            case "outfit": .outfit
            case "model3d": .model3d
            case "stream": .stream
            case "group": .group
            case "live": .live
            case "collab": .collab
            case "agency": .agency
            case "artwork": .artwork
            case "goods": .goods
            default: .other
            }
    }

    var label: LocalizedStringResource {
        switch self {
        case .start: .Journey.kindStart
        case .debut: .Journey.kindDebut
        case .release: .Journey.kindRelease
        case .character: .Journey.kindCharacter
        case .outfit: .Journey.kindOutfit
        case .model3d: .Journey.kindModel3D
        case .stream: .Journey.kindStream
        case .group: .Journey.kindGroup
        case .live: .Journey.kindLive
        case .collab: .Journey.kindCollab
        case .agency: .Journey.kindAgency
        case .artwork: .Journey.kindArtwork
        case .goods: .Journey.kindGoods
        case .other: .Journey.kindOther
        }
    }

    /// The SF Symbol of the timeline marker.
    var systemImage: String {
        switch self {
        case .start: "flag.fill"
        case .debut: "sparkles"
        case .release: "opticaldisc.fill"
        case .character: "person.crop.circle.fill"
        case .outfit: "tshirt.fill"
        case .model3d: "cube.fill"
        case .stream: "dot.radiowaves.left.and.right"
        case .group: "person.3.fill"
        case .live: "music.mic"
        case .collab: "link"
        case .agency: "building.2.fill"
        case .artwork: "paintpalette.fill"
        case .goods: "bag.fill"
        case .other: "circle.fill"
        }
    }
}
