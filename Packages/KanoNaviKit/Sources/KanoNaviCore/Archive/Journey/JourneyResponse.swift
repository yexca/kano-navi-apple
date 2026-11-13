import Foundation

/// `GET /api/journey`: the identities, the timeline and the gallery-only images.
public struct JourneyResponse: Codable, Equatable, Sendable {
    /// The Japan date the data was checked through.
    public var updatedAt: JapanDate
    public var branches: [JourneyBranch]
    /// In page order: by stored date, oldest first.
    public var milestones: [JourneyMilestone]
    /// Images that belong to no milestone and appear only in the gallery.
    public var galleryOnly: [JourneyMedia]

    public func resolvingMedia(against baseURL: URL) -> JourneyResponse {
        var value = self
        value.branches = branches.map { $0.resolvingMedia(against: baseURL) }
        value.milestones = milestones.map { $0.resolvingMedia(against: baseURL) }
        value.galleryOnly = galleryOnly.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// One of Kano's identities on the Journey page.
public struct JourneyBranch: Codable, Equatable, Sendable, Identifiable {
    /// Identity code, such as `singer` or `mahoro`.
    public var id: String
    /// Colour code of the identity, such as `honey`.
    public var tone: String
    /// The year the identity starts, as written (`2010`).
    public var since: String
    public var label: LocalizedText
    /// The identity's portrait. The contract always gives one; `nil` is kept
    /// for a portrait the catalog lacks, which the service writes as `null`.
    public var portrait: JourneyMedia?

    func resolvingMedia(against baseURL: URL) -> JourneyBranch {
        var value = self
        value.portrait = portrait?.resolvingMedia(against: baseURL)
        return value
    }
}

/// One entry of the Journey timeline.
public struct JourneyMilestone: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    /// The date as stored, with its precision (the API's `datePrecision`).
    public var date: JourneyDate
    /// The last day of a period, or `nil`.
    public var dateEnd: JapanDate?
    /// A name written after the date, such as the event `C93`.
    public var dateNote: String?
    /// The branch `id`.
    public var branch: String
    /// Code such as `release`, `debut`, `stream` or `artwork`.
    public var kind: String
    /// Whether the timeline emphasizes it as a key milestone.
    public var highlight: Bool
    public var title: LocalizedText
    public var detail: LocalizedText?
    /// The strongest public page for the entry (provenance).
    public var sourceURL: URL?
    public var links: [JourneyLink]
    /// The Works release whose covers it shows.
    public var releaseID: String?
    /// Catalogued images first, then the release's covers (`origin` `release`).
    public var media: [JourneyMedia]

    enum CodingKeys: String, CodingKey {
        case id, date, datePrecision, dateEnd, dateNote, branch, kind, highlight, title, detail
        case sourceURL = "sourceUrl"
        case links
        case releaseID = "releaseId"
        case media
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(JourneyDate.self, forKey: .date)
        let precision = try container.decode(String.self, forKey: .datePrecision)
        guard precision == date.precision.rawValue else {
            throw DecodingError.dataCorruptedError(
                forKey: .datePrecision, in: container,
                debugDescription: "datePrecision \(precision) does not match date \(date)")
        }
        dateEnd = try container.decodeIfPresent(JapanDate.self, forKey: .dateEnd)
        dateNote = try container.decodeIfPresent(String.self, forKey: .dateNote)
        branch = try container.decode(String.self, forKey: .branch)
        kind = try container.decode(String.self, forKey: .kind)
        highlight = try container.decode(Bool.self, forKey: .highlight)
        title = try container.decode(LocalizedText.self, forKey: .title)
        detail = try container.decodeIfPresent(LocalizedText.self, forKey: .detail)
        sourceURL = try container.decodeIfPresent(URL.self, forKey: .sourceURL)
        links = try container.decode([JourneyLink].self, forKey: .links)
        releaseID = try container.decodeIfPresent(String.self, forKey: .releaseID)
        media = try container.decode([JourneyMedia].self, forKey: .media)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(date.precision.rawValue, forKey: .datePrecision)
        try container.encode(dateEnd, forKey: .dateEnd)
        try container.encode(dateNote, forKey: .dateNote)
        try container.encode(branch, forKey: .branch)
        try container.encode(kind, forKey: .kind)
        try container.encode(highlight, forKey: .highlight)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
        try container.encode(sourceURL, forKey: .sourceURL)
        try container.encode(links, forKey: .links)
        try container.encode(releaseID, forKey: .releaseID)
        try container.encode(media, forKey: .media)
    }

    func resolvingMedia(against baseURL: URL) -> JourneyMilestone {
        var value = self
        value.media = media.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// A further page about a milestone.
public struct JourneyLink: Codable, Equatable, Sendable {
    /// A third-party page (provenance).
    public var url: URL
    public var label: JourneyLinkLabel
}
