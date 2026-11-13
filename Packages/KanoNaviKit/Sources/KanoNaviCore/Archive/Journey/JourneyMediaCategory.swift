import Foundation

/// What a Journey image shows.
/// A code the service adds later decodes as `unknown`.
public enum JourneyMediaCategory: UnknownCode, Hashable {
    case artwork
    case goods
    case frame
    case model
    case cover
    case unknown(String)

    public static let knownValues: [String: JourneyMediaCategory] = [
        "artwork": .artwork,
        "goods": .goods,
        "frame": .frame,
        "model": .model,
        "cover": .cover,
    ]

    public static func unknownValue(_ rawValue: String) -> JourneyMediaCategory {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .artwork: "artwork"
        case .goods: "goods"
        case .frame: "frame"
        case .model: "model"
        case .cover: "cover"
        case .unknown(let value): value
        }
    }
}
