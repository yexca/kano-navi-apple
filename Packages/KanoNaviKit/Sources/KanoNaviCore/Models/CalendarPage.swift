import Foundation

public struct CalendarPage: Codable, Equatable, Sendable {
    public var events: [ScheduleEvent]
    public var scheduleImages: [ScheduleAsset]
    public var adjacent: ArchiveAdjacent
    public var dayCounts: [JapanDate: Int]
    public var total: Int
    public var page: Int
    public var pageSize: Int?
    public var totalPages: Int?
    public var hasNext: Bool
    public var revision: Int
    public init(
        events: [ScheduleEvent], scheduleImages: [ScheduleAsset] = [],
        adjacent: ArchiveAdjacent = ArchiveAdjacent(), dayCounts: [JapanDate: Int] = [:], total: Int,
        page: Int, pageSize: Int? = nil, totalPages: Int? = nil, hasNext: Bool, revision: Int
    ) {
        self.events = events
        self.scheduleImages = scheduleImages
        self.adjacent = adjacent
        self.dayCounts = dayCounts
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.totalPages = totalPages
        self.hasNext = hasNext
        self.revision = revision
    }
    enum CodingKeys: String, CodingKey {
        case events, items, scheduleImages, assets, adjacent, dayCounts, total, page, pageSize,
            totalPages, hasNext, revision
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        events =
            try c.decodeIfPresent([ScheduleEvent].self, forKey: .events) ?? c.decodeIfPresent(
                [ScheduleEvent].self, forKey: .items) ?? []
        scheduleImages =
            try c.decodeIfPresent([ScheduleAsset].self, forKey: .scheduleImages) ?? c.decodeIfPresent(
                [ScheduleAsset].self, forKey: .assets) ?? []
        adjacent = try c.decodeIfPresent(ArchiveAdjacent.self, forKey: .adjacent) ?? ArchiveAdjacent()
        let counts = try c.decodeIfPresent([String: Int].self, forKey: .dayCounts) ?? [:]
        dayCounts = Dictionary(
            uniqueKeysWithValues: counts.compactMap { key, value in
                guard let day = JapanDate(rawValue: key) else { return nil }
                return (day, value)
            })
        total = try c.decode(Int.self, forKey: .total)
        page = try c.decode(Int.self, forKey: .page)
        pageSize = try c.decodeIfPresent(Int.self, forKey: .pageSize)
        totalPages = try c.decodeIfPresent(Int.self, forKey: .totalPages)
        hasNext = try c.decode(Bool.self, forKey: .hasNext)
        revision = try c.decode(Int.self, forKey: .revision)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(events, forKey: .events)
        try c.encode(scheduleImages, forKey: .scheduleImages)
        try c.encode(adjacent, forKey: .adjacent)
        try c.encode(
            Dictionary(uniqueKeysWithValues: dayCounts.map { ($0.key.rawValue, $0.value) }),
            forKey: .dayCounts)
        try c.encode(total, forKey: .total)
        try c.encode(page, forKey: .page)
        try c.encodeIfPresent(pageSize, forKey: .pageSize)
        try c.encodeIfPresent(totalPages, forKey: .totalPages)
        try c.encode(hasNext, forKey: .hasNext)
        try c.encode(revision, forKey: .revision)
    }
}
