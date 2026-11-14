import Foundation

/// `GET /api/posts`: a range of the post archive, or the post timeline
/// newest first, optionally on or before `until`, for one account.
public struct PostsRequest: APIRequest {
    public typealias Response = PostArchivePage
    public let from: JapanDate?
    public let to: JapanDate?
    public let until: JapanDate?
    public let page: Int
    public let pageSize: Int
    public let account: String?
    public let path = "/api/posts"
    public var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let from { items.append(.init(name: "from", value: from.rawValue)) }
        if let to { items.append(.init(name: "to", value: to.rawValue)) }
        if let until { items.append(.init(name: "until", value: until.rawValue)) }
        items.append(.init(name: "page", value: String(page)))
        items.append(.init(name: "pageSize", value: String(pageSize)))
        if let account { items.append(.init(name: "account", value: account)) }
        return items
    }
    public init(
        from: JapanDate? = nil, to: JapanDate? = nil, until: JapanDate? = nil, page: Int = 1,
        pageSize: Int = 30, account: String? = nil
    ) {
        self.from = from
        self.to = to
        self.until = until
        self.page = page
        self.pageSize = pageSize
        self.account = account
    }
    /// A range of at most 42 Japan dates (`from` and `to`) reads part of the
    /// archive; without one, `until` (or nothing, for the newest post) reads
    /// the timeline. The two forms do not mix.
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
        if let account, account.isEmpty { throw RequestValidationError.invalidAccount }
    }
}
