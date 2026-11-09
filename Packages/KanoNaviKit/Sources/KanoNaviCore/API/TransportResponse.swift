import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct TransportResponse: Sendable {
  public var data: Data
  public var statusCode: Int
  public var headers: [String: String]

  public init(data: Data, statusCode: Int, headers: [String: String] = [:]) {
    self.data = data
    self.statusCode = statusCode
    self.headers = headers
  }
}
