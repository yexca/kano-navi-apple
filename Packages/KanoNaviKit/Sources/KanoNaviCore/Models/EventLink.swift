import Foundation

public struct EventLink: Codable, Equatable, Sendable {
  public var platform: EventPlatform
  public var url: URL?
  public var liveStatus: LiveStatus?
  public init(platform: EventPlatform, url: URL?, liveStatus: LiveStatus? = nil) {
    self.platform = platform
    self.url = url
    self.liveStatus = liveStatus
  }
}
