import Foundation

extension WorksUploadVideo: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> WorksUploadVideo {
    var value = self
    value.url = resolveKanoMediaURL(value.url, against: baseURL) ?? value.url
    return value
  }
}
