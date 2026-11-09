import Foundation

public struct VideosMonthsRequest: APIRequest {
  public typealias Response = ArchiveMonthsResponse
  public let path = "/api/videos/months"
  public let queryItems: [URLQueryItem] = []
  public init() {}
  public func validate() throws {}
}
