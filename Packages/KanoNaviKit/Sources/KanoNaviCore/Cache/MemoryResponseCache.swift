import Foundation
import Synchronization

/// Keeps responses in memory, for tests and previews.
public final class MemoryResponseCache: ResponseCache {
    private let values = Mutex<[String: CachedResponse]>([:])
    public init() {}
    public func load(key: String) async -> CachedResponse? { loadImmediately(key: key) }
    public func save(_ response: CachedResponse, key: String) async {
        values.withLock { $0[key] = response }
    }
    public func remove(key: String) async {
        _ = values.withLock { $0.removeValue(forKey: key) }
    }
    public func loadImmediately(key: String) -> CachedResponse? {
        values.withLock { $0[key] }
    }
}
