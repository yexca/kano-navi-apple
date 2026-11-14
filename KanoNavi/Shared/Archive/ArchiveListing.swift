import Foundation

/// The pages of one archive month and filter loaded so far, in server order.
nonisolated struct ArchiveListing<Item: Sendable>: Sendable {
    var items: [Item]
    /// The last page loaded.
    var page: Int
    var hasNext: Bool
    var total: Int
    /// `true` when any loaded page comes from the cache on this device.
    var isFromCache: Bool
    /// When the oldest loaded page was fetched from the service.
    var fetchedAt: Date
    /// Changes whenever the first page is read again, so a later page read
    /// for an earlier listing is not appended to a newer one.
    var generation: Int
    /// The service's data revision of the first page.
    var revision: Int?
    /// `true` once a page read at another revision than the first page has
    /// been appended: the pages are offsets into the list, so a record added
    /// or removed in between may have moved records past the loaded pages.
    var isMixed = false

    init(firstPage: ArchivePage<Item>, generation: Int) {
        items = firstPage.items
        page = firstPage.page
        hasNext = firstPage.hasNext
        total = firstPage.total
        isFromCache = firstPage.isFromCache
        fetchedAt = firstPage.fetchedAt
        self.generation = generation
        revision = firstPage.revision
    }

    /// Appends the next page, leaving out items already listed (a record can
    /// move between pages while the archive changes).
    mutating func append(_ next: ArchivePage<Item>, id: (Item) -> String) {
        let listed = Set(items.map(id))
        items += next.items.filter { listed.contains(id($0)) == false }
        page = next.page
        hasNext = next.hasNext
        total = next.total
        if next.isFromCache {
            isFromCache = true
        }
        fetchedAt = min(fetchedAt, next.fetchedAt)
        if next.revision != revision {
            isMixed = true
        }
    }
}
