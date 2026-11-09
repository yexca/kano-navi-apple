import Foundation

public enum APIError: Error, Equatable, Sendable {
  case offline
  case http(status: Int)
  case decoding(String)
  case incompatible
  case cancelled
}

extension APIError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .offline: "Offline"
    case .http(let status): "HTTP " + String(status)
    case .decoding(let message): "Decoding failed: " + message
    case .incompatible: "Incompatible response"
    case .cancelled: "Cancelled"
    }
  }
}
