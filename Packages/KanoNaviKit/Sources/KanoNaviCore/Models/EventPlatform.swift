import Foundation

/// A closed server code that preserves values introduced by a newer service.
public enum EventPlatform: UnknownCode {
  case youtube
  case bilibili
  case other
  case unknown(String)

  public static let knownValues: [String: EventPlatform] = [
    "youtube": .youtube,
    "bilibili": .bilibili,
    "other": .other,
  ]

  public static func unknownValue(_ rawValue: String) -> EventPlatform {
    .unknown(rawValue)
  }

  public var rawValue: String {
    switch self {
    case .youtube: "youtube"
    case .bilibili: "bilibili"
    case .other: "other"
    case .unknown(let value): value
    }
  }
}
