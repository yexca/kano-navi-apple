import Foundation

/// The kind of page a Journey milestone link opens.
/// A code the service adds later decodes as `unknown`.
public enum JourneyLinkLabel: UnknownCode, Hashable {
    case agency
    case x
    case cancelledRelease
    case unknown(String)

    public static let knownValues: [String: JourneyLinkLabel] = [
        "agency": .agency,
        "x": .x,
        "cancelledRelease": .cancelledRelease,
    ]

    public static func unknownValue(_ rawValue: String) -> JourneyLinkLabel {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .agency: "agency"
        case .x: "x"
        case .cancelledRelease: "cancelledRelease"
        case .unknown(let value): value
        }
    }
}
