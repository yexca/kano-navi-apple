import Foundation

public struct ArchiveMonthsResponse: Codable, Equatable, Sendable {
    public var months: [ArchiveMonth]
    public var revision: Int
}
