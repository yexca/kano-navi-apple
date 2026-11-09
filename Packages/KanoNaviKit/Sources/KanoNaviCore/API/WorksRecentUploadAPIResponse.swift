import Foundation

extension WorksRecentUpload: APIResponse {
    public func resolvingMedia(against baseURL: URL) -> WorksRecentUpload {
        var value = self
        value.url = resolveKanoMediaURL(value.url, against: baseURL) ?? value.url
        if let cover = value.cover {
            value.cover = WorksUploadCover(
                url: resolveKanoMediaURL(cover.url, against: baseURL) ?? cover.url,
                width: cover.width,
                height: cover.height
            )
        }
        return value
    }
}
