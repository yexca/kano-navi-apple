import Foundation

/// A closed server code that preserves values introduced by a newer service.
public enum VideoAvailability: UnknownCode {
  case `public`
  case unlisted
  case members
  case `private`
  case removed
  case unknown(String)

  public static let knownValues: [String: VideoAvailability] = [
    "public": .public,
    "unlisted": .unlisted,
    "members": .members,
    "private": .private,
    "removed": .removed,
  ]

  public static func unknownValue(_ rawValue: String) -> VideoAvailability {
    .unknown(rawValue)
  }

  public var rawValue: String {
    switch self {
    case .public: "public"
    case .unlisted: "unlisted"
    case .members: "members"
    case .private: "private"
    case .removed: "removed"
    case .unknown(let value): value
    }
  }
}
