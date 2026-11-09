import Foundation

public struct SpotlightProjection: Codable, Equatable, Sendable {
    public enum Mode: UnknownCode {
        case next
        case latest
        case unknown(String)

        public static let knownValues: [String: Mode] = [
            "next": .next,
            "latest": .latest,
        ]

        public static func unknownValue(_ rawValue: String) -> Mode {
            .unknown(rawValue)
        }

        public var rawValue: String {
            switch self {
            case .next: "next"
            case .latest: "latest"
            case .unknown(let value): value
            }
        }
    }

    public var mode: Mode
    public var eventID: String?
    public var videoID: String?
    public var liveNow: Bool
    public var isLive: Bool
    public var membersChip: Bool
    public var companionVideoID: String?
    enum CodingKeys: String, CodingKey {
        case mode
        case eventID = "eventId"
        case videoID = "videoId"
        case liveNow, isLive, membersChip
        case companionVideoID = "companionVideoId"
    }
}
