import Foundation

public struct DashboardMeta: Codable, Equatable, Sendable {
  public var fetchedAt: Date?
  public var sourceFetchedAt: [String: Date?]?
  public var lastSync: LastSync?
  public var postWindowDays: Int
  public var xAccounts: [String]
  public var bilibiliAccounts: [String]?
  public var featuredVideoID: String?
  public var eventWindow: EventWindow?
  public var revision: Int?
  enum CodingKeys: String, CodingKey {
    case fetchedAt, sourceFetchedAt, lastSync, postWindowDays, xAccounts, bilibiliAccounts
    case featuredVideoID = "featuredVideoId"
    case eventWindow, revision
  }
}
