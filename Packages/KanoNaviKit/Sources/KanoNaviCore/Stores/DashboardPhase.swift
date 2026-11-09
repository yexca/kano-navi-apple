import Foundation

public enum DashboardPhase: Equatable, Sendable {
  case idle
  case loading
  case refreshing
  case failed(APIError)
}
