import Foundation

/// A closed server code that preserves values introduced by a newer service.
public enum TranslationOrigin: UnknownCode {
    case manual
    case platform
    case machine
    case unknown(String)

    public static let knownValues: [String: TranslationOrigin] = [
        "manual": .manual,
        "platform": .platform,
        "machine": .machine,
    ]

    public static func unknownValue(_ rawValue: String) -> TranslationOrigin {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .manual: "manual"
        case .platform: "platform"
        case .machine: "machine"
        case .unknown(let value): value
        }
    }
}
