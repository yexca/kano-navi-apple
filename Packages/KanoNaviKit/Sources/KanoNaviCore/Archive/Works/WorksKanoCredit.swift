import Foundation

/// A further credit of Kano's on a participation track.
/// A code the service adds later decodes as `unknown`.
public enum WorksKanoCredit: UnknownCode, Hashable {
    case lyrics
    case composition
    case arrangement
    case animation
    case other
    case unknown(String)

    public static let knownValues: [String: WorksKanoCredit] = [
        "lyrics": .lyrics,
        "composition": .composition,
        "arrangement": .arrangement,
        "animation": .animation,
        "other": .other,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksKanoCredit {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .lyrics: "lyrics"
        case .composition: "composition"
        case .arrangement: "arrangement"
        case .animation: "animation"
        case .other: "other"
        case .unknown(let value): value
        }
    }
}
