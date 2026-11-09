import Foundation

/// A decoded public API response that can validate its contract and resolve media URLs.
public protocol APIResponse: Codable, Sendable {
  /// Validates response requirements that are stricter than JSON decoding.
  func validated() throws

  /// Returns a copy with relative media URLs resolved against the API base URL.
  func resolvingMedia(against baseURL: URL) -> Self
}

extension APIResponse {
  public func validated() throws {}

  public func resolvingMedia(against _: URL) -> Self { self }
}

func resolveKanoMediaURL(_ value: URL?, against baseURL: URL) -> URL? {
  guard let value else { return nil }
  guard value.scheme == nil else { return value }
  return URL(string: value.absoluteString, relativeTo: baseURL)?.absoluteURL
}
