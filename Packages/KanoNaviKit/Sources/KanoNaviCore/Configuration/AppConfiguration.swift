import Foundation

/// Build settings the app reads from its Info.plist.
///
/// `Config/Base.xcconfig` sets `API_BASE_URL` and `MAINLAND_API_BASE_URL`,
/// and `Config/Info.plist` exposes them under ``apiBaseURLKey`` and
/// ``mainlandAPIBaseURLKey``.
public struct AppConfiguration: Equatable, Sendable {
    public static let apiBaseURLKey = "KanoNaviAPIBaseURL"
    public static let mainlandAPIBaseURLKey = "KanoNaviMainlandAPIBaseURL"

    /// The configuration of the running app or extension.
    public static var main: AppConfiguration {
        do {
            return try AppConfiguration(infoDictionary: Bundle.main.infoDictionary ?? [:])
        } catch {
            fatalError("Invalid build configuration: \(error)")
        }
    }

    /// The origin of the default Kano Navi service, in Japan. It always uses
    /// HTTPS.
    public let apiBaseURL: URL
    /// The origin of the service in mainland China, or `nil` when the build
    /// sets none. It always uses HTTPS.
    public let mainlandAPIBaseURL: URL?

    public init(infoDictionary: [String: Any]) throws(AppConfigurationError) {
        guard let rawValue = infoDictionary[Self.apiBaseURLKey] as? String else {
            throw .missingAPIBaseURL
        }
        apiBaseURL = try Self.httpsURL(rawValue)

        if let mainland = infoDictionary[Self.mainlandAPIBaseURLKey] as? String, mainland.isEmpty == false {
            mainlandAPIBaseURL = try Self.httpsURL(mainland)
        } else {
            mainlandAPIBaseURL = nil
        }
    }

    /// The address of a built-in server, or `nil` when the build sets none.
    public func baseURL(of server: BuiltInServer) -> URL? {
        switch server {
        case .japan: apiBaseURL
        case .mainlandChina: mainlandAPIBaseURL
        }
    }

    /// The built-in servers the build sets, the default first.
    public var builtInServers: [ServiceServer] {
        BuiltInServer.allCases.compactMap { server in
            baseURL(of: server).map { ServiceServer(builtIn: server, baseURL: $0) }
        }
    }

    private static func httpsURL(_ rawValue: String) throws(AppConfigurationError) -> URL {
        guard
            let url = URL(string: rawValue),
            url.scheme?.lowercased() == "https",
            let host = url.host(),
            host.isEmpty == false
        else {
            throw .invalidAPIBaseURL(rawValue)
        }
        return url
    }
}
