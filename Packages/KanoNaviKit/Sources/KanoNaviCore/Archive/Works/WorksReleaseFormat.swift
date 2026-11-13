import Foundation

/// The format of a personal release.
/// A code the service adds later decodes as `unknown`.
public enum WorksReleaseFormat: UnknownCode, Hashable {
    case album
    case single
    case ep
    case doujin
    case unknown(String)

    public static let knownValues: [String: WorksReleaseFormat] = [
        "album": .album,
        "single": .single,
        "ep": .ep,
        "doujin": .doujin,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksReleaseFormat {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .album: "album"
        case .single: "single"
        case .ep: "ep"
        case .doujin: "doujin"
        case .unknown(let value): value
        }
    }
}
