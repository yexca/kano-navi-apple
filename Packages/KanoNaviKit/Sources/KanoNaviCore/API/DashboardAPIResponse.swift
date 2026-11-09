import Foundation

extension Dashboard: APIResponse {
  public func validated() throws {
    guard projection?.version == 1 else { throw APIError.incompatible }
    guard events.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
    guard videos.allSatisfy({ $0.view != nil }) else { throw APIError.incompatible }
  }

  public func resolvingMedia(against baseURL: URL) -> Dashboard {
    var value = self
    value.profile.avatarURL = resolveKanoMediaURL(value.profile.avatarURL, against: baseURL)
    value.profile.bannerURL = resolveKanoMediaURL(value.profile.bannerURL, against: baseURL)
    value.posts = value.posts.map { $0.resolvingMedia(against: baseURL) }
    value.events = value.events.map { $0.resolvingMedia(against: baseURL) }
    value.videos = value.videos.map { $0.resolvingMedia(against: baseURL) }
    value.focus = value.focus?.resolvingMedia(against: baseURL)
    value.assets = value.assets.map { $0.resolvingMedia(against: baseURL) }
    value.scheduleImages = value.scheduleImages.map { $0.resolvingMedia(against: baseURL) }
    return value
  }
}
