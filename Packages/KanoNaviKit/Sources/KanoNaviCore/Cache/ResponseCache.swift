import Foundation

public protocol ResponseCache: Sendable {
    func load(key: String) async -> CachedResponse?
    func save(_ response: CachedResponse, key: String) async
    func remove(key: String) async

    /// The cached response for `key`, read on the caller's thread without
    /// waiting, or `nil` when there is none or the cache cannot answer at
    /// once. A store calls it once while it is created, so the first frame
    /// can show the saved copy; keep it to one small read.
    func loadImmediately(key: String) -> CachedResponse?
}

extension ResponseCache {
    /// A cache that can only answer asynchronously reports nothing.
    public func loadImmediately(key: String) -> CachedResponse? { nil }
}
