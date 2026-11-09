import Foundation

public struct VideoArchivePage: Codable, Equatable, Sendable {
    public var items: [Video]
    public var adjacent: ArchiveAdjacent
    public var total: Int
    public var page: Int
    public var pageSize: Int?
    public var totalPages: Int?
    public var hasNext: Bool
    public var revision: Int
    public var categoryCounts: [String: Int]?
}
