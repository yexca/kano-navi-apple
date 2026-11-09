import Foundation

public struct DashboardSummary: Codable, Equatable, Sendable {
  public var nextEvent: ScheduleEvent?
  public var nextStream: Video?
  public var latestVideo: Video?
  public var latestPost: Post?
  public var counts: DashboardCounts?
}
