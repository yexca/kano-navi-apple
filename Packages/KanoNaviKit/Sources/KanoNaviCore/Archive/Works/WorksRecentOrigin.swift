import Foundation

/// Why a recent upload is listed: by its tag, form and format (`auto`) or by an
/// operator's decision (`operator`).
/// A code the service adds later decodes as `unknown`.
public enum WorksRecentOrigin: UnknownCode, Hashable {
    case auto
    case `operator`
    case unknown(String)

    public static let knownValues: [String: WorksRecentOrigin] = [
        "auto": .auto,
        "operator": .operator,
    ]

    public static func unknownValue(_ rawValue: String) -> WorksRecentOrigin {
        .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .auto: "auto"
        case .operator: "operator"
        case .unknown(let value): value
        }
    }
}
