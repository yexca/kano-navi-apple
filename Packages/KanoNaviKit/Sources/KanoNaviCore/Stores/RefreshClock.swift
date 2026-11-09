import Foundation

public protocol RefreshClock: Sendable {
  var now: Date { get }
  func sleep(for duration: Duration) async throws
}
