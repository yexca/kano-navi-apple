import Foundation

public actor MemoryResponseCache: ResponseCache {
  private var values: [String: CachedResponse] = [:]
  public init() {}
  public func load(key: String) async -> CachedResponse? { values[key] }
  public func save(_ response: CachedResponse, key: String) async { values[key] = response }
  public func remove(key: String) async { values.removeValue(forKey: key) }
}
