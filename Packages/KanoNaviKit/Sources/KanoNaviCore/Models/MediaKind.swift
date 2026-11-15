import Foundation

/// What a post image shows: a photo, or the still of an X video or GIF,
/// which plays only on X. A code the service adds later decodes as
/// `unknown`.
public enum MediaKind: UnknownCode, Hashable {
    case photo
    case video
    case gif
    case unknown(String)

    public static let knownValues: [String: MediaKind] = [
        "photo": .photo,
        "video": .video,
        "gif": .gif,
    ]

    public static func unknownValue(_ rawValue: String) -> MediaKind {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .photo: "photo"
        case .video: "video"
        case .gif: "gif"
        case .unknown(let value): value
        }
    }
}
