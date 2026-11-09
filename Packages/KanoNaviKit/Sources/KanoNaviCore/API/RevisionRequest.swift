import Foundation

public struct RevisionRequest: APIRequest {
    public typealias Response = RevisionResponse
    public let since: Int?
    public let path = "/api/dashboard/revision"
    public var queryItems: [URLQueryItem] {
        since.map { [URLQueryItem(name: "since", value: String($0))] } ?? []
    }
    public init(since: Int? = nil) { self.since = since }
    public func validate() throws {}
}
