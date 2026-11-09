import Foundation

extension WorksUploadsResponse: APIResponse {
  public func resolvingMedia(against baseURL: URL) -> WorksUploadsResponse {
    var value = self
    for key in value.uploads.keys {
      guard var item = value.uploads[key] else { continue }
      if let cover = item.cover {
        item.cover = WorksUploadCover(
          url: resolveKanoMediaURL(cover.url, against: baseURL) ?? cover.url,
          width: cover.width,
          height: cover.height
        )
      }
      item.videos = item.videos.map { $0.resolvingMedia(against: baseURL) }
      value.uploads[key] = item
    }
    value.recent = value.recent?.map { $0.resolvingMedia(against: baseURL) }
    return value
  }
}
