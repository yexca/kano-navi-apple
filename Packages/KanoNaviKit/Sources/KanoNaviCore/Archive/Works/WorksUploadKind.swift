import Foundation

/// The kind of an upload in the Works upload list.
/// A code the service adds later decodes as `unknown`.
public enum WorksUploadKind: UnknownCode, Hashable {
    case cover
    case original
    case mv
    case project
    case compilation
    case game
    case composition
    case unknown(String)

    public static let knownValues: [String: WorksUploadKind] = [
        "cover": .cover,
        "original": .original,
        "mv": .mv,
        "project": .project,
        "compilation": .compilation,
        "game": .game,
        "composition": .composition,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksUploadKind {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .cover: "cover"
        case .original: "original"
        case .mv: "mv"
        case .project: "project"
        case .compilation: "compilation"
        case .game: "game"
        case .composition: "composition"
        case .unknown(let value): value
        }
    }
}
