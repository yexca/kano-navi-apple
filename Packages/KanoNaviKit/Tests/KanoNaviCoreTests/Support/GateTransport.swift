import Foundation

@testable import KanoNaviCore

actor GateTransport: APITransport {
  private let response: TransportResponse
  private var releaseContinuation: CheckedContinuation<Void, Never>?
  private(set) var started = false

  init(response: TransportResponse) {
    self.response = response
  }

  func send(_: URLRequest) async throws -> TransportResponse {
    started = true
    await withCheckedContinuation { continuation in
      releaseContinuation = continuation
    }
    return response
  }

  func release() {
    releaseContinuation?.resume()
    releaseContinuation = nil
  }
}
