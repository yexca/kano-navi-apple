import Foundation

public protocol ResponseCache: Sendable {
  func load(key: String) async -> CachedResponse?
  func save(_ response: CachedResponse, key: String) async
  func remove(key: String) async
}
