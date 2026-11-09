import Foundation

public struct PostsMonthsRequest: APIRequest {
  public typealias Response = ArchiveMonthsResponse
  public let path = "/api/posts/months"
  public let queryItems: [URLQueryItem] = []
  public init() {}
  public func validate() throws {}
}
