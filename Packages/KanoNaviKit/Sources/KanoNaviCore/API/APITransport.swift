import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol APITransport: Sendable {
  func send(_ request: URLRequest) async throws -> TransportResponse
}
