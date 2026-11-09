import Foundation

public struct HealthRequest: APIRequest {
    public typealias Response = HealthResponse
    public let path = "/api/health"
    public let queryItems: [URLQueryItem] = []
    public init() {}
    public func validate() throws {}
}
