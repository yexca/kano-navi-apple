import Foundation

public protocol APIRequest: Sendable {
  associatedtype Response: APIResponse
  var path: String { get }
  var queryItems: [URLQueryItem] { get }
  func validate() throws
}
