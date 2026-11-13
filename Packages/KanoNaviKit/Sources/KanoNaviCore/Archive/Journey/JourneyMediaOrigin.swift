import Foundation

/// Where a Journey media item comes from: the Journey catalog (`fixed`) or a
/// cover of the milestone's Works release (`release`).
/// A code the service adds later decodes as `unknown`.
public enum JourneyMediaOrigin: UnknownCode, Hashable {
    case fixed
    case release
    case unknown(String)

    public static let knownValues: [String: JourneyMediaOrigin] = [
        "fixed": .fixed,
        "release": .release,
    ]

    public static func unknownValue(_ rawValue: String) -> JourneyMediaOrigin {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .fixed: "fixed"
        case .release: "release"
        case .unknown(let value): value
        }
    }
}
