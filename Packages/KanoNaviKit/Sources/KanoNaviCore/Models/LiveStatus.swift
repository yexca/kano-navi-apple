import Foundation

/// A closed server code that preserves values introduced by a newer service.
public enum LiveStatus: UnknownCode {
  case live
  case upcoming
  case ended
  case unknown(String)

  public static let knownValues: [String: LiveStatus] = [
    "live": .live,
    "upcoming": .upcoming,
    "ended": .ended,
  ]

  public static func unknownValue(_ rawValue: String) -> LiveStatus {
    .unknown(rawValue)
  }

  public var rawValue: String {
    switch self {
    case .live: "live"
    case .upcoming: "upcoming"
    case .ended: "ended"
    case .unknown(let value): value
    }
  }
}
