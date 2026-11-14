import Foundation

public struct PostArchivePage: Codable, Equatable, Sendable {
    public var items: [Post]
    public var adjacent: ArchiveAdjacent
    public var total: Int
    public var page: Int
    public var pageSize: Int?
    public var totalPages: Int?
    public var hasNext: Bool
    public var revision: Int
    public var accountCounts: [String: Int]?
    /// The page's post accounts' avatars, keyed and valued as
    /// ``Dashboard/accountAvatars``.
    public var accountAvatars: [String: URL?]?
    public init(
        items: [Post], adjacent: ArchiveAdjacent = ArchiveAdjacent(), total: Int, page: Int,
        pageSize: Int? = nil, totalPages: Int? = nil, hasNext: Bool, revision: Int,
        accountCounts: [String: Int]? = nil, accountAvatars: [String: URL?]? = nil
    ) {
        self.items = items
        self.adjacent = adjacent
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.totalPages = totalPages
        self.hasNext = hasNext
        self.revision = revision
        self.accountCounts = accountCounts
        self.accountAvatars = accountAvatars
    }
}
