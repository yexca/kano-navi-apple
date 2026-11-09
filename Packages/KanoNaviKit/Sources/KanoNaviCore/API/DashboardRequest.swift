import Foundation

public struct DashboardRequest: APIRequest {
    public typealias Response = Dashboard
    public let days: Int
    public let path = "/api/dashboard"
    public var queryItems: [URLQueryItem] { [URLQueryItem(name: "days", value: String(days))] }
    public init(days: Int = 7) { self.days = min(max(days, 1), 30) }
    public func validate() throws {}
}
