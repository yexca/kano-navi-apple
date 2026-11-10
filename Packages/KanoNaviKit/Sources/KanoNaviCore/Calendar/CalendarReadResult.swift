import Foundation

/// The merged calendar pages of a range and where they came from.
public struct CalendarReadResult: Equatable, Sendable {
    /// All pages merged in server order.
    public var page: CalendarPage
    /// `true` when the service could not be read and every page comes from
    /// the cache.
    public var isFromCache: Bool
    /// When the data was fetched from the service: the end of the read for
    /// fresh pages, or the oldest page's fetch time for cached pages.
    public var fetchedAt: Date

    public init(page: CalendarPage, isFromCache: Bool, fetchedAt: Date) {
        self.page = page
        self.isFromCache = isFromCache
        self.fetchedAt = fetchedAt
    }
}
