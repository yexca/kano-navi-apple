import Foundation

// The archive reads carry no `revision`: their data ships with a service
// release, so they revalidate through their ETag alone.

/// `GET /api/journey`.
public struct JourneyRequest: APIRequest {
    public typealias Response = JourneyResponse
    public let path = "/api/journey"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}

/// `GET /api/works`.
public struct WorksRequest: APIRequest {
    public typealias Response = WorksResponse
    public let path = "/api/works"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}

/// `GET /api/works/upload-list`.
public struct WorksUploadListRequest: APIRequest {
    public typealias Response = WorksUploadListResponse
    public let path = "/api/works/upload-list"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}

/// `GET /api/lineblog`.
public struct LineBlogIndexRequest: APIRequest {
    public typealias Response = LineBlogIndexResponse
    public let path = "/api/lineblog"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}

/// `GET /api/lineblog/posts/{id}`. An ID that is not an article number (ASCII
/// digits without a leading zero) fails `validate()` with
/// `RequestValidationError.invalidArticleID` before anything is sent; an
/// unknown number is the service's 404.
public struct LineBlogPostRequest: APIRequest {
    public typealias Response = LineBlogPostResponse
    public let id: String
    public var path: String { "/api/lineblog/posts/" + id }
    public let queryItems: [URLQueryItem] = []
    public init(id: String) { self.id = id }
    public init(id: Int) { self.id = String(id) }
    public func validate() throws { try validateLineBlogArticleID(id) }
}

/// `GET /api/lineblog/posts/{id}/comments`, validated like `LineBlogPostRequest`.
public struct LineBlogCommentsRequest: APIRequest {
    public typealias Response = LineBlogCommentsResponse
    public let articleID: String
    public var path: String { "/api/lineblog/posts/" + articleID + "/comments" }
    public let queryItems: [URLQueryItem] = []
    public init(articleID: String) { self.articleID = articleID }
    public init(articleID: Int) { self.articleID = String(articleID) }
    public func validate() throws { try validateLineBlogArticleID(articleID) }
}

private func validateLineBlogArticleID(_ id: String) throws {
    guard let first = id.first, first != "0", id.allSatisfy({ $0.isASCII && $0.isNumber }) else {
        throw RequestValidationError.invalidArticleID
    }
}
