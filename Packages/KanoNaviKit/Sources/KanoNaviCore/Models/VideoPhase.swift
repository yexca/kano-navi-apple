import Foundation

public enum VideoPhase: UnknownCode {
    case upcoming
    case live
    case started
    case past
    case cancelled
    case unknown(String)

    public static let knownValues: [String: VideoPhase] = [
        "upcoming": .upcoming,
        "live": .live,
        "started": .started,
        "past": .past,
        "cancelled": .cancelled,
    ]

    public static func unknownValue(_ rawValue: String) -> VideoPhase {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .upcoming: "upcoming"
        case .live: "live"
        case .started: "started"
        case .past: "past"
        case .cancelled: "cancelled"
        case .unknown(let value): value
        }
    }
}
