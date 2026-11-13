import Foundation

/// Where a link or card of an article leads: another archived article, which
/// the app opens itself, or a page outside the app.
nonisolated enum LineBlogLinkTarget: Hashable, Sendable {
    /// An archived article, by its number.
    case article(id: String)
    /// A web page, opened for the reader outside the app and never fetched.
    case outside(URL)

    /// The scheme of the address an in-app article link carries inside text.
    private static let articleScheme = "kanonavi-lineblog-article"

    /// The target of a link written as `href` with the API's `articleId`.
    ///
    /// An article number wins over the address. Without one, only an `http`
    /// or `https` address with a host is a link; anything else (a script, a
    /// relative path) returns `nil` and its text is drawn as plain text.
    init?(href: URL?, articleID: String?) {
        if let articleID, Self.isArticleNumber(articleID) {
            self = .article(id: articleID)
        } else if let href, let outside = Self.outsideURL(href) {
            self = .outside(outside)
        } else {
            return nil
        }
    }

    /// The target of an address a text link was tapped with: the reverse of
    /// `url`. Returns `nil` for an address the reader never wrote.
    init?(opened url: URL) {
        if url.scheme == Self.articleScheme {
            let id = url.absoluteString.dropFirst(Self.articleScheme.count + 1)
            guard Self.isArticleNumber(String(id)) else { return nil }
            self = .article(id: String(id))
        } else if let outside = Self.outsideURL(url) {
            self = .outside(outside)
        } else {
            return nil
        }
    }

    /// The address a text link carries for this target. An article gets an
    /// address of the app's own, which `init(opened:)` reads back.
    var url: URL {
        switch self {
        case .article(let id): URL(string: "\(Self.articleScheme):\(id)") ?? URL(filePath: "/")
        case .outside(let url): url
        }
    }

    /// `url` when it is a web address to open outside, else `nil`.
    static func outsideURL(_ url: URL?) -> URL? {
        guard let url, let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
            url.host()?.isEmpty == false
        else { return nil }
        return url
    }

    /// An article number as the API writes it: ASCII digits without a
    /// leading zero.
    private static func isArticleNumber(_ id: String) -> Bool {
        guard let first = id.first, first != "0" else { return false }
        return id.allSatisfy { $0.isASCII && $0.isNumber }
    }
}
