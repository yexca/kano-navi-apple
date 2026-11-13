import Foundation

/// What the credited person did for a Works image.
/// A code the service adds later decodes as `unknown`.
public enum WorksImageCreditRole: UnknownCode, Hashable {
    case scan
    case photo
    case fan
    case unknown(String)

    public static let knownValues: [String: WorksImageCreditRole] = [
        "scan": .scan,
        "photo": .photo,
        "fan": .fan,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksImageCreditRole {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .scan: "scan"
        case .photo: "photo"
        case .fan: "fan"
        case .unknown(let value): value
        }
    }
}
