import Foundation

extension MediaItem: APIResponse {
    public func resolvingMedia(against baseURL: URL) -> MediaItem {
        var value = self
        value.url = resolveKanoMediaURL(value.url, against: baseURL)
        value.sourceURL = resolveKanoMediaURL(value.sourceURL, against: baseURL)
        return value
    }
}
