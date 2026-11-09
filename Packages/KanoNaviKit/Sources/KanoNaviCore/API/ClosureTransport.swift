import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ClosureTransport: APITransport {
  private let handler: @Sendable (URLRequest) async throws -> TransportResponse

  public init(handler: @escaping @Sendable (URLRequest) async throws -> TransportResponse) {
    self.handler = handler
  }

  public func send(_ request: URLRequest) async throws -> TransportResponse {
    try await handler(request)
  }
}
