import Foundation

public struct ScheduleAsset: Codable, Equatable, Sendable {
    public var id: String
    public var kind: String
    public var label: String?
    public var alt: String?
    public var weekStart: JapanDate?
    public var periodStart: JapanDate?
    public var periodEnd: JapanDate?
    public var periodBasis: String?
    public var updatedAt: Date?
    public var url: URL?
    public var sourceURL: URL?
    public var mediaStatus: String
    enum CodingKeys: String, CodingKey {
        case id, kind, label, alt, weekStart, periodStart, periodEnd, periodBasis, updatedAt, url
        case sourceURL = "sourceUrl"
        case mediaStatus
    }
}
