import Foundation

public struct HealthResponse: Codable, Equatable, Sendable {
  public var ok: Bool
  public var service: String
  public var now: Date
  public var lastSync: HealthLastSync?
  public init(ok: Bool, service: String, now: Date, lastSync: HealthLastSync? = nil) {
    self.ok = ok
    self.service = service
    self.now = now
    self.lastSync = lastSync
  }
}
