import Foundation

extension PostArchivePage: APIResponse {
    public func resolvingMedia(against baseURL: URL) -> PostArchivePage {
        var value = self
        value.items = value.items.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}
