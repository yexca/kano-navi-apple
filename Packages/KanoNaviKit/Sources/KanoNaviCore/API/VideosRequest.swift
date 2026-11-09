import Foundation

public struct VideosRequest: APIRequest {
    public typealias Response = VideoArchivePage
    public let from: JapanDate?
    public let to: JapanDate?
    public let until: JapanDate?
    public let page: Int
    public let pageSize: Int
    public let category: String?
    public let path = "/api/videos"
    public var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let from { items.append(.init(name: "from", value: from.rawValue)) }
        if let to { items.append(.init(name: "to", value: to.rawValue)) }
        if let until { items.append(.init(name: "until", value: until.rawValue)) }
        items += [
            .init(name: "page", value: String(page)), .init(name: "pageSize", value: String(pageSize)),
        ]
        if let category { items.append(.init(name: "category", value: category)) }
        return items
    }
    public init(
        from: JapanDate? = nil, to: JapanDate? = nil, until: JapanDate? = nil, page: Int = 1,
        pageSize: Int = 30, category: String? = nil
    ) {
        self.from = from
        self.to = to
        self.until = until
        self.page = page
        self.pageSize = pageSize
        self.category = category
    }
    public func validate() throws {
        if let from, let to {
            guard from <= to, from.addingDays(41) >= to, until == nil else {
                throw RequestValidationError.invalidDateRange
            }
        } else if from != nil || to != nil {
            throw RequestValidationError.invalidDateRange
        }
        guard page > 0 else { throw RequestValidationError.invalidPage }
        guard (1...50).contains(pageSize) else { throw RequestValidationError.invalidPageSize }
        if let category, !["game", "talk", "song", "other"].contains(category) {
            throw RequestValidationError.invalidCategory
        }
    }
}
