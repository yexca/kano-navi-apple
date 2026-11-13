import Foundation

/// What a Journey image's `date` is the date of.
/// A code the service adds later decodes as `unknown`.
public enum JourneyMediaDateKind: UnknownCode, Hashable {
    case post
    case announcement
    case publication
    case stream
    case outfit
    case capture
    case release
    case unknown(String)

    public static let knownValues: [String: JourneyMediaDateKind] = [
        "post": .post,
        "announcement": .announcement,
        "publication": .publication,
        "stream": .stream,
        "outfit": .outfit,
        "capture": .capture,
        "release": .release,
    ]

    public static func unknownValue(_ rawValue: String) -> JourneyMediaDateKind {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .post: "post"
        case .announcement: "announcement"
        case .publication: "publication"
        case .stream: "stream"
        case .outfit: "outfit"
        case .capture: "capture"
        case .release: "release"
        case .unknown(let value): value
        }
    }
}
