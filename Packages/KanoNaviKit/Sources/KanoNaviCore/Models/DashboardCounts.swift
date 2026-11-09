import Foundation

public struct DashboardCounts: Codable, Equatable, Sendable {
  public var posts: Int
  public var upcomingEvents: Int
  public var videos: Int
}
