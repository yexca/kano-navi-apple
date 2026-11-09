import Foundation

public struct RevisionResponse: Codable, Equatable, Sendable {
  public var revision: Int
  public var changed: Bool?
  public init(revision: Int) { self.revision = revision }
}
