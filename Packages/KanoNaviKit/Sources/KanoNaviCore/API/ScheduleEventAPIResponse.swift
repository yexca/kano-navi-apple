import Foundation

extension ScheduleEvent: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> ScheduleEvent {
    var value = self
    value.url = resolveKanoMediaURL(value.url, against: baseURL)
    value.liveURL = resolveKanoMediaURL(value.liveURL, against: baseURL)
    value.links = value.links?.map { link in
      var result = link
      result.url = resolveKanoMediaURL(result.url, against: baseURL)
      return result
    }
    return value
  }
}
