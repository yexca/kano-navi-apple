/// Why the Uploads screen lists nothing, so it can say so in the right
/// words: a search that found nothing is not an empty collection.
nonisolated enum WorksUploadsEmptyState: Equatable, Sendable {
    /// The search query matches no upload.
    case search
    /// The chosen kind has no upload.
    case kind
    /// The collection lists no upload at all.
    case list

    /// `nil` while there are rows to show.
    init?(isEmpty: Bool, isSearching: Bool, kind: String?) {
        guard isEmpty else { return nil }
        if isSearching {
            self = .search
        } else if kind != nil {
            self = .kind
        } else {
            self = .list
        }
    }
}
