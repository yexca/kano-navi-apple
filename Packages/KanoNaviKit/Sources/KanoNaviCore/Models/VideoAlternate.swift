import Foundation

public struct VideoAlternate: Codable, Equatable, Sendable {
  public var source: String
  public var url: URL
  public init(source: String, url: URL) {
    self.source = source
    self.url = url
  }
}
