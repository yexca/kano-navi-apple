import Foundation

public struct LastSync: Codable, Equatable, Sendable {
  public var status: String
  public var startedAt: Date?
  public var finishedAt: Date?
}
