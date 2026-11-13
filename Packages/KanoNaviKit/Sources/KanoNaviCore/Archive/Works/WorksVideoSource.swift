import Foundation

/// The platform of a stored Works video.
/// A code the service adds later decodes as `unknown`.
public enum WorksVideoSource: UnknownCode, Hashable {
    case youtube
    case bilibili
    case unknown(String)

    public static let knownValues: [String: WorksVideoSource] = [
        "youtube": .youtube,
        "bilibili": .bilibili,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksVideoSource {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .youtube: "youtube"
        case .bilibili: "bilibili"
        case .unknown(let value): value
        }
    }
}
