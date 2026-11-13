import KanoNaviCore

/// A response cache with room for one response, whatever its key: the
/// document tests read a single request, so they need not know how the
/// client names it.
actor SingleDocumentCache: ResponseCache {
    private var response: CachedResponse?

    init(holding response: CachedResponse? = nil) {
        self.response = response
    }

    func load(key: String) async -> CachedResponse? { response }

    func save(_ response: CachedResponse, key: String) async {
        self.response = response
    }

    func remove(key: String) async {
        response = nil
    }

    /// Forgets the response, as when the system empties the caches
    /// directory.
    func clear() {
        response = nil
    }
}
