import Foundation

public struct WorksUploadsResponse: Codable, Equatable, Sendable {
  public var updatedAt: JapanDate
  public var revision: Int
  public var uploads: [String: WorksUploadState]
  public var recent: [WorksRecentUpload]?
  public var recentTotal: Int?
}
