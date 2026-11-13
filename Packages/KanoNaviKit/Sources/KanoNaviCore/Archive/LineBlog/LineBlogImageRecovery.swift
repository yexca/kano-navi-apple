import Foundation

/// How a LINE BLOG picture added after the recovery archive was found.
/// A code the service adds later decodes as `unknown`.
public enum LineBlogImageRecovery: UnknownCode, Hashable {
    case standIn
    case tweet
    case unknown(String)

    public static let knownValues: [String: LineBlogImageRecovery] = [
        "stand-in": .standIn,
        "tweet": .tweet,
    ]

    public static func unknownValue(_ rawValue: String) -> LineBlogImageRecovery {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .standIn: "stand-in"
        case .tweet: "tweet"
        case .unknown(let value): value
        }
    }
}
