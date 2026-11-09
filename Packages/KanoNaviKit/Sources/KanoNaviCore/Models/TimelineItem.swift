import Foundation

public struct TimelineItem: Codable, Equatable, Sendable {
  public var id: Int
  public var year: String
  public var title: String
  public var detail: String?
}
