import Foundation

extension VideoArchivePage: APIResponse {
    public func resolvingMedia(against baseURL: URL) -> VideoArchivePage {
        var value = self
        value.items = value.items.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}
