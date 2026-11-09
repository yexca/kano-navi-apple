import Foundation

extension ScheduleAsset: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> ScheduleAsset {
    var value = self
    value.url = resolveKanoMediaURL(value.url, against: baseURL)
    value.sourceURL = resolveKanoMediaURL(value.sourceURL, against: baseURL)
    return value
  }
}
