import Foundation

public struct HealthLastSync: Codable, Equatable, Sendable {
  public var id: Int?
  public var source: String?
  public var startedAt: Date?
  public var finishedAt: Date?
  public var status: String
  public var message: String?
  public init(
    id: Int? = nil, source: String? = nil, startedAt: Date? = nil, finishedAt: Date? = nil,
    status: String, message: String? = nil
  ) {
    self.id = id
    self.source = source
    self.startedAt = startedAt
    self.finishedAt = finishedAt
    self.status = status
    self.message = message
  }
}
