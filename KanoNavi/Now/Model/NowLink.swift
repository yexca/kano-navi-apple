import Foundation
import KanoNaviCore

/// One external link on a Now card. The app only opens it for the user with
/// `openURL`; it never fetches the page.
struct NowLink: Equatable, Identifiable {
    enum Destination: Equatable {
        /// A page on YouTube or Bilibili.
        case platform(EventPlatform)
        /// A page on another site, named by its host.
        case site(host: String)
        /// The entry's announcement post.
        case announcement
    }

    var destination: Destination
    var url: URL
    /// Whether that platform reports the broadcast live.
    var isLive: Bool

    var id: URL { url }

    /// A link to a platform page. A platform without its own name, such as
    /// `other`, is named by the page's host.
    static func page(on platform: EventPlatform, url: URL, isLive: Bool = false) -> NowLink {
        switch platform {
        case .youtube, .bilibili:
            NowLink(destination: .platform(platform), url: url, isLive: isLive)
        case .other, .unknown:
            NowLink(destination: .site(host: displayHost(of: url)), url: url, isLive: isLive)
        }
    }

    /// The host without a leading `www.`, or the whole URL when it has none.
    static func displayHost(of url: URL) -> String {
        guard let host = url.host(), host.isEmpty == false else { return url.absoluteString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

extension EventPlatform {
    /// The platform a video's `source` names.
    init(videoSource source: String) {
        self = Self.knownValues[source] ?? .unknown(source)
    }
}
