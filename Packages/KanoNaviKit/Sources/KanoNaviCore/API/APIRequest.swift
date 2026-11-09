import Foundation

public protocol APIRequest: Sendable {
    associatedtype Response: Codable & Sendable
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    func validate() throws
}

public struct HealthRequest: APIRequest {
    public typealias Response = HealthResponse
    public let path = "/api/health"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}

public struct DashboardRequest: APIRequest {
    public typealias Response = Dashboard
    public let days: Int
    public let path = "/api/dashboard"
    public var queryItems: [URLQueryItem] { [URLQueryItem(name: "days", value: String(days))] }
    public init(days: Int = 7) { self.days = min(max(days, 1), 30) }
    public func validate() throws {}
}

public struct RevisionRequest: APIRequest {
    public typealias Response = RevisionResponse
    public let since: Int?
    public let path = "/api/dashboard/revision"
    public var queryItems: [URLQueryItem] { since.map { [URLQueryItem(name: "since", value: String($0))] } ?? [] }
    public init(since: Int? = nil) { self.since = since }
    public func validate() throws {}
}

public enum RequestValidationError: Error, Equatable, Sendable { case invalidDateRange; case invalidPage; case invalidPageSize; case invalidCategory; case invalidAccount }

public struct CalendarRequest: APIRequest {
    public typealias Response = CalendarPage
    public let from: JapanDate
    public let to: JapanDate
    public let page: Int
    public let pageSize: Int
    public let path = "/api/calendar"
    public var queryItems: [URLQueryItem] { [URLQueryItem(name: "from", value: from.rawValue), URLQueryItem(name: "to", value: to.rawValue), URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "pageSize", value: String(pageSize))] }
    public init(from: JapanDate, to: JapanDate, page: Int = 1, pageSize: Int = 100) { self.from = from; self.to = to; self.page = page; self.pageSize = pageSize }
    public func validate() throws { guard from <= to, from.addingDays(41) >= to else { throw RequestValidationError.invalidDateRange }; guard page > 0 else { throw RequestValidationError.invalidPage }; guard (1...100).contains(pageSize) else { throw RequestValidationError.invalidPageSize } }
}

public struct PostsRequest: APIRequest {
    public typealias Response = PostArchivePage
    public let from: JapanDate?
    public let to: JapanDate?
    public let until: JapanDate?
    public let page: Int
    public let pageSize: Int
    public let account: String?
    public let path = "/api/posts"
    public var queryItems: [URLQueryItem] { var items = [URLQueryItem](); if let from { items.append(.init(name: "from", value: from.rawValue)) }; if let to { items.append(.init(name: "to", value: to.rawValue)) }; if let until { items.append(.init(name: "until", value: until.rawValue)) }; items.append(.init(name: "page", value: String(page))); items.append(.init(name: "pageSize", value: String(pageSize))); if let account { items.append(.init(name: "account", value: account)) }; return items }
    public init(from: JapanDate? = nil, to: JapanDate? = nil, until: JapanDate? = nil, page: Int = 1, pageSize: Int = 30, account: String? = nil) { self.from = from; self.to = to; self.until = until; self.page = page; self.pageSize = pageSize; self.account = account }
    public func validate() throws { if let from, let to { guard from <= to, from.addingDays(41) >= to else { throw RequestValidationError.invalidDateRange }; guard until == nil else { throw RequestValidationError.invalidDateRange } } else if from != nil || to != nil || (until != nil && (from != nil || to != nil)) { throw RequestValidationError.invalidDateRange }; guard page > 0 else { throw RequestValidationError.invalidPage }; guard (1...50).contains(pageSize) else { throw RequestValidationError.invalidPageSize }; if let account, account.isEmpty { throw RequestValidationError.invalidAccount } }
}

public struct VideosRequest: APIRequest {
    public typealias Response = VideoArchivePage
    public let from: JapanDate?
    public let to: JapanDate?
    public let until: JapanDate?
    public let page: Int
    public let pageSize: Int
    public let category: String?
    public let path = "/api/videos"
    public var queryItems: [URLQueryItem] { var items = [URLQueryItem](); if let from { items.append(.init(name: "from", value: from.rawValue)) }; if let to { items.append(.init(name: "to", value: to.rawValue)) }; if let until { items.append(.init(name: "until", value: until.rawValue)) }; items += [.init(name: "page", value: String(page)), .init(name: "pageSize", value: String(pageSize))]; if let category { items.append(.init(name: "category", value: category)) }; return items }
    public init(from: JapanDate? = nil, to: JapanDate? = nil, until: JapanDate? = nil, page: Int = 1, pageSize: Int = 30, category: String? = nil) { self.from = from; self.to = to; self.until = until; self.page = page; self.pageSize = pageSize; self.category = category }
    public func validate() throws { if let from, let to { guard from <= to, from.addingDays(41) >= to, until == nil else { throw RequestValidationError.invalidDateRange } } else if from != nil || to != nil { throw RequestValidationError.invalidDateRange }; guard page > 0 else { throw RequestValidationError.invalidPage }; guard (1...50).contains(pageSize) else { throw RequestValidationError.invalidPageSize }; if let category, !["game", "talk", "song", "other"].contains(category) { throw RequestValidationError.invalidCategory } }
}

public struct MonthsRequest<Response: Codable & Sendable>: APIRequest {
    public let path: String
    public let queryItems: [URLQueryItem] = []
    public init(path: String) { self.path = path }
    public func validate() throws {}
}

public struct PostsMonthsRequest: APIRequest { public typealias Response = ArchiveMonthsResponse; public let path = "/api/posts/months"; public let queryItems: [URLQueryItem] = []; public init() {}; public func validate() throws {} }
public struct VideosMonthsRequest: APIRequest { public typealias Response = ArchiveMonthsResponse; public let path = "/api/videos/months"; public let queryItems: [URLQueryItem] = []; public init() {}; public func validate() throws {} }
public struct WorksUploadsRequest: APIRequest { public typealias Response = WorksUploadsResponse; public let path = "/api/works/uploads"; public let queryItems: [URLQueryItem] = []; public init() {}; public func validate() throws {} }
