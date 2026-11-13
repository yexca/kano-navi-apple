import Foundation
import KanoNaviCore

/// Where a Works image file was taken from. The page is only ever opened
/// for the reader; the app never loads it.
nonisolated enum WorksImageProvenance: Equatable, Sendable {
    /// The page the file was taken from, named by its host.
    case page(URL, host: String)
    /// The site named instead of a page, as written.
    case site(String)

    init?(_ image: WorksImage) {
        if let url = image.sourceURL {
            self = .page(url, host: Self.displayHost(of: url))
        } else if let label = image.sourceLabel, label.isEmpty == false {
            self = .site(label)
        } else {
            return nil
        }
    }

    /// The name shown for the source.
    var name: String {
        switch self {
        case .page(_, let host): host
        case .site(let label): label
        }
    }

    /// The host without a leading `www.`, or the whole address when it has none.
    static func displayHost(of url: URL) -> String {
        guard let host = url.host(), host.isEmpty == false else { return url.absoluteString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
