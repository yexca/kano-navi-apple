import Foundation

/// Kano's part in a participation work.
/// A code the service adds later decodes as `unknown`.
public enum WorksParticipationRole: UnknownCode, Hashable {
    case vocal
    case lyrics
    case composition
    case voice
    case guest
    case unknown(String)

    public static let knownValues: [String: WorksParticipationRole] = [
        "vocal": .vocal,
        "lyrics": .lyrics,
        "composition": .composition,
        "voice": .voice,
        "guest": .guest,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksParticipationRole {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .vocal: "vocal"
        case .lyrics: "lyrics"
        case .composition: "composition"
        case .voice: "voice"
        case .guest: "guest"
        case .unknown(let value): value
        }
    }
}
