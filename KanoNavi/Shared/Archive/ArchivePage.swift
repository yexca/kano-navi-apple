import Foundation

/// One page of an archive read, as the screens need it: the items, whether
/// another page follows, the month's counts per filter code and where the
/// page came from.
nonisolated struct ArchivePage<Item: Sendable>: Sendable {
    var items: [Item]
    var page: Int
    var hasNext: Bool
    /// The items in the month under the page's filter.
    var total: Int
    /// The month's items per filter code, whatever the filter. Keys are the
    /// API's codes, such as `game` or a lowercase account handle.
    var counts: [String: Int]
    /// `true` when the service could not be read and the page comes from the
    /// cache on this device.
    var isFromCache: Bool
    /// When the page was fetched from the service.
    var fetchedAt: Date
}

extension ArchivePage: Equatable where Item: Equatable {}
