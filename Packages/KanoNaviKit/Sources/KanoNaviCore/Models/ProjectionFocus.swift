import Foundation

public struct ProjectionFocus: Codable, Equatable, Sendable {
  public var eventIDs: [String]
  public var videoIDs: [String]
  public init(eventIDs: [String], videoIDs: [String]) {
    self.eventIDs = eventIDs
    self.videoIDs = videoIDs
  }
  enum CodingKeys: String, CodingKey {
    case eventIDs = "eventIds"
    case videoIDs = "videoIds"
  }
}
