import Foundation

/// A closed server code that preserves values introduced by a newer service.
public protocol UnknownCode: Codable, Equatable, Sendable {
  static var knownValues: [String: Self] { get }
  static func unknownValue(_ rawValue: String) -> Self
  var rawValue: String { get }
}

extension UnknownCode {
  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    self = Self.knownValues[value] ?? Self.unknownValue(value)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
