import Foundation

/// `GET /api/works`: the collection's personal releases and participation
/// works, oldest first as the collection lists them.
public struct WorksResponse: Codable, Equatable, Sendable {
    /// The Japan date the collection was checked through.
    public var updatedAt: JapanDate
    public var summary: WorksSummary
    public var personal: [WorksRelease]
    public var participation: [WorksParticipation]

    public func resolvingMedia(against baseURL: URL) -> WorksResponse {
        var value = self
        value.personal = personal.map { $0.resolvingMedia(against: baseURL) }
        value.participation = participation.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// The collection's counts and year span.
public struct WorksSummary: Codable, Equatable, Sendable {
    public var personal: Int
    public var participation: Int
    public var uploads: Int
    public var firstYear: Int
    public var lastYear: Int
}

extension [WorksImage] {
    func resolvingMedia(against baseURL: URL) -> [WorksImage] {
        map { $0.resolvingMedia(against: baseURL) }
    }
}
