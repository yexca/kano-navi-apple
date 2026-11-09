import Foundation

public struct HealthLastSync: Codable, Equatable, Sendable {
    public var id: Int?
    public var source: String?
    public var startedAt: Date?
    public var finishedAt: Date?
    public var status: String
    public var message: String?
    public init(id: Int? = nil, source: String? = nil, startedAt: Date? = nil, finishedAt: Date? = nil, status: String, message: String? = nil) { self.id = id; self.source = source; self.startedAt = startedAt; self.finishedAt = finishedAt; self.status = status; self.message = message }
}

public struct HealthResponse: Codable, Equatable, Sendable {
    public var ok: Bool
    public var service: String
    public var now: Date
    public var lastSync: HealthLastSync?
    public init(ok: Bool, service: String, now: Date, lastSync: HealthLastSync? = nil) { self.ok = ok; self.service = service; self.now = now; self.lastSync = lastSync }
}

public struct RevisionResponse: Codable, Equatable, Sendable {
    public var revision: Int
    public var changed: Bool?
    public init(revision: Int) { self.revision = revision }
}
