import Foundation

public enum EventState: UnknownCode {
  case upcoming
  case live
  case open
  case done
  case pending
  case cancelled
  case cancellationReview
  case unknown(String)

  public static let knownValues: [String: EventState] = [
    "upcoming": .upcoming,
    "live": .live,
    "open": .open,
    "done": .done,
    "pending": .pending,
    "cancelled": .cancelled,
    "cancellation_review": .cancellationReview,
  ]

  public static func unknownValue(_ rawValue: String) -> EventState {
    .unknown(rawValue)
  }

  public var rawValue: String {
    switch self {
    case .upcoming: "upcoming"
    case .live: "live"
    case .open: "open"
    case .done: "done"
    case .pending: "pending"
    case .cancelled: "cancelled"
    case .cancellationReview: "cancellation_review"
    case .unknown(let value): value
    }
  }
}
