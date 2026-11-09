import Foundation

public struct LiveNow: Codable, Equatable, Sendable {
  public var platform: EventPlatform
  public var url: URL
  public var title: String
  public var startedAt: Date
  public init(platform: EventPlatform, url: URL, title: String, startedAt: Date) {
    self.platform = platform
    self.url = url
    self.title = title
    self.startedAt = startedAt
  }
}
