import Foundation

public enum VideoPhase: Codable, Equatable, Sendable { case upcoming, live, started, past, cancelled, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "upcoming": .upcoming; case "live": .live; case "started": .started; case "past": .past; case "cancelled": .cancelled; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .upcoming:"upcoming"; case .live:"live"; case .started:"started"; case .past:"past"; case .cancelled:"cancelled"; case .unknown(let v):v } }
}

public enum VideoFormCode: Codable, Equatable, Sendable { case short, upcoming, stream, archive, premiere, video, unknown(String)
    public init(from decoder: Decoder) throws { let c = try decoder.singleValueContainer(); let v = try c.decode(String.self); self = switch v { case "short": .short; case "upcoming": .upcoming; case "stream": .stream; case "archive": .archive; case "premiere": .premiere; case "video": .video; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .short:"short"; case .upcoming:"upcoming"; case .stream:"stream"; case .archive:"archive"; case .premiere:"premiere"; case .video:"video"; case .unknown(let v):v } }
}

public struct VideoView: Codable, Equatable, Sendable {
    public var phase: VideoPhase
    public var formCode: VideoFormCode?
    public var shelfGroup: String
    public var latestEligible: Bool
    public var focusEligible: Bool
    public var tagContext: String
    public init(phase: VideoPhase, formCode: VideoFormCode? = nil, shelfGroup: String, latestEligible: Bool, focusEligible: Bool, tagContext: String) { self.phase = phase; self.formCode = formCode; self.shelfGroup = shelfGroup; self.latestEligible = latestEligible; self.focusEligible = focusEligible; self.tagContext = tagContext }
}

public struct VideoAlternate: Codable, Equatable, Sendable {
    public var source: String
    public var url: URL
    public init(source: String, url: URL) { self.source = source; self.url = url }
}

public struct Video: Codable, Equatable, Sendable {
    public var id: String
    public var source: String
    public var title: String
    public var publishedAt: Date?
    public var scheduledAt: Date?
    public var endsAt: Date?
    public var url: URL
    public var thumbnailURL: URL?
    public var thumbnailStatus: String
    public var kind: String?
    public var tag: String?
    public var isUpcoming: Bool
    public var isCancelled: Bool?
    public var liveStatus: LiveStatus?
    public var durationSeconds: Int?
    public var isShort: Bool?
    public var availability: VideoAvailability?
    public var translations: Translations?
    public var sourceLanguage: String?
    public var alternates: [VideoAlternate]?
    public var view: VideoView?
    enum CodingKeys: String, CodingKey { case id, source, title, publishedAt, scheduledAt, endsAt, url, thumbnailURL = "thumbnailUrl", thumbnailStatus, kind, tag, isUpcoming, isCancelled, liveStatus, durationSeconds, isShort, availability, translations, sourceLanguage, alternates, view }
}
