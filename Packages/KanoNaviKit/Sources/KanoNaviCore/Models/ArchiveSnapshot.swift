import Foundation

public struct ArchiveSnapshot<Item: Codable & Equatable & Sendable>: Codable, Equatable, Sendable
where Item: Sendable {
    public var items: [Item]
    public var adjacent: ArchiveAdjacent
    public var total: Int
    public var page: Int
    public var hasNext: Bool
    public var revision: Int
    public var dayCounts: [JapanDate: Int]?
    public var accountCounts: [String: Int]?
    public var categoryCounts: [String: Int]?
    public init(
        items: [Item], adjacent: ArchiveAdjacent, total: Int, page: Int, hasNext: Bool, revision: Int,
        dayCounts: [JapanDate: Int]? = nil, accountCounts: [String: Int]? = nil,
        categoryCounts: [String: Int]? = nil
    ) {
        self.items = items
        self.adjacent = adjacent
        self.total = total
        self.page = page
        self.hasNext = hasNext
        self.revision = revision
        self.dayCounts = dayCounts
        self.accountCounts = accountCounts
        self.categoryCounts = categoryCounts
    }
}
