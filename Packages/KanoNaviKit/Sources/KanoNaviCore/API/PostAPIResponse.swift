import Foundation

extension Post: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> Post {
    var value = self
    value.url = resolveKanoMediaURL(value.url, against: baseURL) ?? value.url
    value.accountURL = resolveKanoMediaURL(value.accountURL, against: baseURL)
    value.mediaURL = resolveKanoMediaURL(value.mediaURL, against: baseURL)
    value.media = value.media.map { $0.resolvingMedia(against: baseURL) }
    return value
  }
}
