import Foundation

/// A closed server code that preserves values introduced by a newer service.
public enum SaleMark: UnknownCode {
  case opens
  case closes
  case unknown(String)

  public static let knownValues: [String: SaleMark] = [
    "opens": .opens,
    "closes": .closes,
  ]

  public static func unknownValue(_ rawValue: String) -> SaleMark {
    .unknown(rawValue)
  }

  public var rawValue: String {
    switch self {
    case .opens: "opens"
    case .closes: "closes"
    case .unknown(let value): value
    }
  }
}
