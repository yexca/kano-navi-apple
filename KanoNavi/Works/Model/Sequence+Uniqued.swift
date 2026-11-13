extension Sequence {
    /// The elements in order, leaving out one whose `key` an earlier one
    /// had. The API should not repeat a code or a page; when it does, a
    /// list shows it once instead of two rows of one identity.
    nonisolated func uniqued<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var seen: Set<Key> = []
        return filter { seen.insert(key($0)).inserted }
    }
}

extension Sequence where Element: Hashable {
    /// The elements in order, each once.
    nonisolated func uniqued() -> [Element] {
        uniqued { $0 }
    }
}
