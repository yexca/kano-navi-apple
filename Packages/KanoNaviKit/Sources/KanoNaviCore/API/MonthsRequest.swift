import Foundation

public struct MonthsRequest<Response: APIResponse>: APIRequest {
  public let path: String
  public let queryItems: [URLQueryItem] = []
  public init(path: String) { self.path = path }
  public func validate() throws {}
}
