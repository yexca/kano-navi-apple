import Foundation

/// The icon a LINE BLOG comment rating is drawn with.
/// A code the service adds later decodes as `unknown`.
public enum LineBlogRatingIcon: UnknownCode, Hashable {
    case star
    case face
    case unknown(String)

    public static let knownValues: [String: LineBlogRatingIcon] = [
        "star": .star,
        "face": .face,
    ]

    public static func unknownValue(_ rawValue: String) -> LineBlogRatingIcon {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .star: "star"
        case .face: "face"
        case .unknown(let value): value
        }
    }
}
