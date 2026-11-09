import Foundation

extension Video: APIResponse {
    public func resolvingMedia(against baseURL: URL) -> Video {
        var value = self
        value.url = resolveKanoMediaURL(value.url, against: baseURL) ?? value.url
        value.thumbnailURL = resolveKanoMediaURL(value.thumbnailURL, against: baseURL)
        value.alternates = value.alternates?.map { alternate in
            var result = alternate
            result.url = resolveKanoMediaURL(result.url, against: baseURL) ?? result.url
            return result
        }
        return value
    }
}
