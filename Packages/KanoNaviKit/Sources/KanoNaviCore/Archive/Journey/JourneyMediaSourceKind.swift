import Foundation

/// Who published a Journey image's file.
/// A code the service adds later decodes as `unknown`.
public enum JourneyMediaSourceKind: UnknownCode, Hashable {
    case artist
    case organizer
    case creator
    case video
    case streamArchive
    case shop
    case brand
    case agency
    case officialCover
    case thirdPartyCover
    case unknown(String)

    public static let knownValues: [String: JourneyMediaSourceKind] = [
        "artist": .artist,
        "organizer": .organizer,
        "creator": .creator,
        "video": .video,
        "streamArchive": .streamArchive,
        "shop": .shop,
        "brand": .brand,
        "agency": .agency,
        "officialCover": .officialCover,
        "thirdPartyCover": .thirdPartyCover,
    ]

    public static func unknownValue(_ rawValue: String) -> JourneyMediaSourceKind {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .artist: "artist"
        case .organizer: "organizer"
        case .creator: "creator"
        case .video: "video"
        case .streamArchive: "streamArchive"
        case .shop: "shop"
        case .brand: "brand"
        case .agency: "agency"
        case .officialCover: "officialCover"
        case .thirdPartyCover: "thirdPartyCover"
        case .unknown(let value): value
        }
    }
}
