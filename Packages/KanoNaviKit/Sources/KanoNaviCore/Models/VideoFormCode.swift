import Foundation

public enum VideoFormCode: UnknownCode {
    case short
    case upcoming
    case stream
    case archive
    case premiere
    case video
    case unknown(String)

    public static let knownValues: [String: VideoFormCode] = [
        "short": .short,
        "upcoming": .upcoming,
        "stream": .stream,
        "archive": .archive,
        "premiere": .premiere,
        "video": .video,
    ]

    public static func unknownValue(_ rawValue: String) -> VideoFormCode {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .short: "short"
        case .upcoming: "upcoming"
        case .stream: "stream"
        case .archive: "archive"
        case .premiere: "premiere"
        case .video: "video"
        case .unknown(let value): value
        }
    }
}
