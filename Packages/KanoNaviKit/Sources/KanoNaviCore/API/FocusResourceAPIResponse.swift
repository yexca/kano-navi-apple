import Foundation

extension FocusResource: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> FocusResource {
    var value = self
    value.imageURL = resolveKanoMediaURL(value.imageURL, against: baseURL)
    value.url = resolveKanoMediaURL(value.url, against: baseURL)
    value.sourceURL = resolveKanoMediaURL(value.sourceURL, against: baseURL)
    return value
  }
}
