import Foundation

@testable import KanoNaviCore

struct FixtureTransport: APITransport {
  let response: TransportResponse

  func send(_: URLRequest) async throws -> TransportResponse {
    response
  }
}
