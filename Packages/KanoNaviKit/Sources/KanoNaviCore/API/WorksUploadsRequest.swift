import Foundation

public struct WorksUploadsRequest: APIRequest {
  public typealias Response = WorksUploadsResponse
  public let path = "/api/works/uploads"
  public let queryItems: [URLQueryItem] = []
  public init() {}
  public func validate() throws {}
}
