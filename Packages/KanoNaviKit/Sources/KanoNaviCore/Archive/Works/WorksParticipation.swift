import Foundation

/// A work Kano took part in. Text fields are as the record writes them.
public struct WorksParticipation: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var date: JapanDate
    public var title: String
    public var roles: [WorksParticipationRole]
    /// Codes such as `digital`, `bonus`, `drama`, `cdr`, `boxSet`, `notForSale` or `promo`.
    public var forms: [String]
    /// The unit name, or `nil` (the service sends `null` rather than an empty string).
    public var unit: String?
    /// Empty when unknown.
    public var label: String
    /// Empty when unknown.
    public var event: String
    /// Empty when unknown.
    public var catalog: String
    /// The page the record follows (provenance).
    public var sourceURL: URL?
    public var cover: WorksImage?
    public var tracks: [WorksParticipationTrack]

    enum CodingKeys: String, CodingKey {
        case id, date, title, roles, forms, unit, label, event, catalog
        case sourceURL = "sourceUrl"
        case cover, tracks
    }

    func resolvingMedia(against baseURL: URL) -> WorksParticipation {
        var value = self
        value.cover = cover?.resolvingMedia(against: baseURL)
        return value
    }
}

/// A track of a participation work.
public struct WorksParticipationTrack: Codable, Equatable, Sendable {
    public var disc: Int
    public var no: Int
    public var title: String
    /// The database's artist line, as written.
    public var credit: String
    /// Whether Kano took part in the track.
    public var kano: Bool
    /// Her further credits on the track.
    public var kanoCredits: [WorksKanoCredit]
}
