import Foundation

/// A Kano Navi service the app can read: a built-in one, or one the person
/// added by name and address.
public struct ServiceServer: Codable, Hashable, Sendable, Identifiable {
    /// A ``BuiltInServer`` raw value, or `custom-` and a UUID.
    public let id: String
    /// The name the person gave an added server. A built-in server's is
    /// empty; the app shows its localized name instead.
    public let name: String
    /// The service's HTTPS origin, with an optional path and no trailing
    /// slash.
    public let baseURL: URL

    public init(id: String, name: String, baseURL: URL) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
    }

    public init(builtIn: BuiltInServer, baseURL: URL) {
        self.init(id: builtIn.rawValue, name: "", baseURL: baseURL)
    }

    /// A server the person added, with a new identity.
    public static func custom(name: String, baseURL: URL) -> ServiceServer {
        ServiceServer(id: "custom-" + UUID().uuidString, name: name, baseURL: baseURL)
    }

    /// The built-in server this is, or `nil` for one the person added.
    public var builtIn: BuiltInServer? {
        BuiltInServer(rawValue: id)
    }

    /// The address as the person reads it: the host, its port, and its path,
    /// without the scheme.
    public var displayAddress: String {
        ServerAddress.display(baseURL)
    }
}
