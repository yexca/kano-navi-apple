import Foundation

public struct EventLink: Codable, Equatable, Sendable {
    public var platform: EventPlatform
    public var url: URL?
    public var liveStatus: LiveStatus?
    public init(platform: EventPlatform, url: URL?, liveStatus: LiveStatus? = nil) { self.platform = platform; self.url = url; self.liveStatus = liveStatus }
}

public struct ScheduleEvent: Codable, Equatable, Sendable {
    public var id: String
    public var source: String
    public var platform: EventPlatform?
    public var title: String
    public var detail: String?
    public var startsOn: JapanDate
    public var startsAt: Date?
    public var endsAt: Date?
    public var endsOn: JapanDate?
    public var timezone: String
    public var timePrecision: String
    public var status: String?
    public var eventType: String
    public var saleMark: SaleMark?
    public var saleWindow: SaleWindow?
    public var tag: String?
    public var url: URL?
    public var provenance: String
    public var manualLocked: Bool
    public var isUpcoming: Bool
    public var cancellationStatus: String
    public var cancellationReason: String?
    public var cancellationEvidence: String?
    public var liveStatus: LiveStatus?
    public var liveURL: URL?
    public var platforms: [EventPlatform]?
    public var links: [EventLink]?
    public var translations: Translations?
    public var sourceLanguage: String?
    public var view: EventView?
    enum CodingKeys: String, CodingKey { case id, source, platform, title, detail, startsOn, startsAt, endsAt, endsOn, timezone, timePrecision, status, eventType, saleMark, saleWindow, tag, url, provenance, manualLocked, isUpcoming, cancellationStatus, cancellationReason, cancellationEvidence, liveStatus, liveURL = "liveUrl", platforms, links, translations, sourceLanguage, view }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id); source = try c.decode(String.self, forKey: .source); platform = try c.decodeIfPresent(EventPlatform.self, forKey: .platform)
        title = try c.decode(String.self, forKey: .title); detail = try c.decodeIfPresent(String.self, forKey: .detail); startsOn = try c.decode(JapanDate.self, forKey: .startsOn); startsAt = try c.decodeIfPresent(Date.self, forKey: .startsAt); endsAt = try c.decodeIfPresent(Date.self, forKey: .endsAt); endsOn = try c.decodeIfPresent(JapanDate.self, forKey: .endsOn)
        timezone = try c.decodeIfPresent(String.self, forKey: .timezone) ?? "Asia/Tokyo"; timePrecision = try c.decodeIfPresent(String.self, forKey: .timePrecision) ?? "unknown"; status = try c.decodeIfPresent(String.self, forKey: .status); eventType = try c.decodeIfPresent(String.self, forKey: .eventType) ?? "event"; saleMark = try c.decodeIfPresent(SaleMark.self, forKey: .saleMark); saleWindow = try c.decodeIfPresent(SaleWindow.self, forKey: .saleWindow); tag = try c.decodeIfPresent(String.self, forKey: .tag); url = try c.decodeIfPresent(URL.self, forKey: .url); provenance = try c.decodeIfPresent(String.self, forKey: .provenance) ?? "unknown"; manualLocked = try c.decodeIfPresent(Bool.self, forKey: .manualLocked) ?? false; isUpcoming = try c.decodeIfPresent(Bool.self, forKey: .isUpcoming) ?? false; cancellationStatus = try c.decodeIfPresent(String.self, forKey: .cancellationStatus) ?? "none"; cancellationReason = try c.decodeIfPresent(String.self, forKey: .cancellationReason); cancellationEvidence = try c.decodeIfPresent(String.self, forKey: .cancellationEvidence); liveStatus = try c.decodeIfPresent(LiveStatus.self, forKey: .liveStatus); liveURL = try c.decodeIfPresent(URL.self, forKey: .liveURL); platforms = try c.decodeIfPresent([EventPlatform].self, forKey: .platforms); links = try c.decodeIfPresent([EventLink].self, forKey: .links); translations = try c.decodeIfPresent(Translations.self, forKey: .translations); sourceLanguage = try c.decodeIfPresent(String.self, forKey: .sourceLanguage); view = try c.decodeIfPresent(EventView.self, forKey: .view)
    }
}
