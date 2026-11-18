import Foundation

/// Reads the address of a server the person types in.
public enum ServerAddress {
    /// The HTTPS origin the person typed, with an optional path. A bare host
    /// gets `https://`; the host is lowercased and a trailing slash dropped.
    /// User info, a query, or a fragment makes the address invalid.
    public static func parse(_ input: String) throws(ServerAddressError) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { throw .empty }

        let withScheme = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard var components = URLComponents(string: withScheme) else { throw .invalid }
        guard components.scheme?.lowercased() == "https" else { throw .notHTTPS }
        guard let host = components.host, host.isEmpty == false,
            components.user == nil, components.password == nil,
            components.query == nil, components.fragment == nil
        else {
            throw .invalid
        }

        components.scheme = "https"
        components.host = host.lowercased()
        while components.path.hasSuffix("/") {
            components.path.removeLast()
        }
        guard let url = components.url else { throw .invalid }
        return url
    }

    /// The host, its port, and its path, without the scheme.
    public static func display(_ url: URL) -> String {
        var text = url.host() ?? url.absoluteString
        if let port = url.port {
            text += ":" + String(port)
        }
        let path = url.path()
        if path.isEmpty == false, path != "/" {
            text += path
        }
        return text
    }
}
